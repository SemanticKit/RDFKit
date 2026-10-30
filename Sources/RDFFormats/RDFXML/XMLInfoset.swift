import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// The parts of an XML Information Set that RDF 1.2 XML Syntax reads
/// (Syntax Data Model),
/// built from a namespace-aware XML parse of one document.
///
/// Namespace information items have no data model events, but
/// `rdf:parseType="Literal"` content keeps them: Exclusive XML
/// Canonicalization renders the declarations its elements use.
struct XMLInfoset {
    /// An element information item.
    struct Element {
        var prefix: String?
        var localName: String
        var namespaceName: String?
        var attributes: [Attribute]
        var children: [Item]
        var line: Int
        var column: Int

        /// The element's name as written, `prefix:local` or `local`.
        var qualifiedName: String {
            prefix.map { "\($0):\(localName)" } ?? localName
        }
    }

    /// An attribute information item. Namespace declarations are not
    /// attributes in the Infoset, so they never appear here.
    struct Attribute {
        var prefix: String?
        var localName: String
        var namespaceName: String?
        var normalizedValue: String

        var qualifiedName: String {
            prefix.map { "\($0):\(localName)" } ?? localName
        }
    }

    /// A child information item of an element.
    enum Item {
        case element(Element)
        /// Character information items, including CDATA sections.
        case text(String)
        case comment(String)
        case processingInstruction(target: String, data: String)
    }

    /// The document element.
    let documentElement: Element

    /// The namespace name of the `xml` prefix (Namespaces in XML).
    static let xmlNamespace = "http://www.w3.org/XML/1998/namespace"

    /// Parses `document` as namespace-well-formed XML.
    init(_ document: String) throws {
        let builder = Builder()
        let parser = XMLParser(data: Data(document.utf8))
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true
        parser.shouldResolveExternalEntities = false
        parser.delegate = builder
        let parsed = parser.parse()
        if let error = builder.error {
            throw error
        }
        guard parsed, let root = builder.root else {
            throw SyntaxError(line: parser.lineNumber, column: parser.columnNumber, message: "the document is not well-formed XML")
        }
        documentElement = root
    }

    /// Collects the parser's events into elements.
    private final class Builder: NSObject, XMLParserDelegate {
        var root: Element?
        var error: SyntaxError?
        /// Open elements, innermost last.
        private var open: [Element] = []
        /// In-scope prefix mappings for each open element, innermost last.
        private var scopes: [[String: String]] = [["xml": XMLInfoset.xmlNamespace]]
        private var pending: [String: String] = [:]

        func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
            pending[prefix] = namespaceURI
        }

        func parser(
            _ parser: XMLParser,
            didStartElement elementName: String,
            namespaceURI: String?,
            qualifiedName: String?,
            attributes: [String: String] = [:]
        ) {
            var scope = scopes[scopes.count - 1]
            scope.merge(pending) { $1 }
            pending = [:]
            scopes.append(scope)

            let (prefix, local) = Self.split(qualifiedName ?? elementName)
            var element = Element(
                prefix: prefix,
                localName: local,
                namespaceName: Self.namespace(prefix ?? "", in: scope),
                attributes: [],
                children: [],
                line: parser.lineNumber,
                column: parser.columnNumber
            )
            for (name, value) in attributes.sorted(by: { $0.key < $1.key }) {
                let (prefix, local) = Self.split(name)
                var namespace: String?
                if let prefix {
                    guard let declared = scope[prefix] else {
                        fail(parser, "the prefix '\(prefix)' of attribute '\(name)' is not declared")
                        return
                    }
                    namespace = declared
                }
                element.attributes.append(Attribute(prefix: prefix, localName: local, namespaceName: namespace, normalizedValue: value))
            }
            open.append(element)
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
            guard let element = open.popLast() else { return }
            scopes.removeLast()
            if open.isEmpty {
                root = element
            } else {
                open[open.count - 1].children.append(.element(element))
            }
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            append(.text(string))
        }

        func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
            append(.text(whitespaceString))
        }

        func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
            append(.text(String(decoding: CDATABlock, as: UTF8.self)))
        }

        func parser(_ parser: XMLParser, foundComment comment: String) {
            append(.comment(comment))
        }

        func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
            append(.processingInstruction(target: target, data: data ?? ""))
        }

        func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
            fail(parser, "the document is not well-formed XML (\((parseError as NSError).code))")
        }

        func parser(_ parser: XMLParser, validationErrorOccurred validationError: any Error) {
            fail(parser, "the document is not valid XML (\((validationError as NSError).code))")
        }

        private func append(_ item: Item) {
            guard !open.isEmpty else { return }
            open[open.count - 1].children.append(item)
        }

        private func fail(_ parser: XMLParser, _ message: String) {
            if error == nil {
                error = SyntaxError(line: parser.lineNumber, column: parser.columnNumber, message: message)
            }
            parser.abortParsing()
        }

        private static func split(_ name: String) -> (String?, String) {
            guard let colon = name.firstIndex(of: ":") else { return (nil, name) }
            return (String(name[..<colon]), String(name[name.index(after: colon)...]))
        }

        private static func namespace(_ prefix: String, in scope: [String: String]) -> String? {
            guard let namespace = scope[prefix], !namespace.isEmpty else { return nil }
            return namespace
        }
    }
}
