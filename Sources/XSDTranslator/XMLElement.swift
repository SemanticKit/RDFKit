import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// An element of a schema document, as a namespace-aware XML parse gives
/// it: its expanded name, its attributes, the prefixes in scope (for the
/// QName values of `base`), its child elements and its text.
struct SchemaElement {
    let namespace: String?
    let localName: String
    let attributes: [String: String]
    let prefixes: [String: String]
    var children: [SchemaElement] = []
    var text = ""

    /// The child elements named `localName` in `namespace`.
    func children(_ localName: String, in namespace: String) -> [SchemaElement] {
        children.filter { $0.localName == localName && $0.namespace == namespace }
    }

    /// The namespace name and local name a QName attribute value denotes,
    /// resolved with the prefixes in scope (Namespaces in XML §4).
    func resolve(qualifiedName: String) throws -> (namespace: String?, localName: String) {
        guard let colon = qualifiedName.firstIndex(of: ":") else { return (prefixes[""], qualifiedName) }
        let prefix = String(qualifiedName[..<colon])
        guard let namespace = prefixes[prefix] else {
            throw TranslationError(description: "the prefix '\(prefix)' of '\(qualifiedName)' is not declared")
        }
        return (namespace, String(qualifiedName[qualifiedName.index(after: colon)...]))
    }

    /// Parses a document. External entities, the DTDs the schema documents
    /// name, are not read.
    init(document path: String) throws {
        let data = try Data(contentsOf: URL(filePath: path))
        let builder = Builder()
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true
        parser.shouldResolveExternalEntities = false
        parser.delegate = builder
        guard parser.parse(), let root = builder.root else {
            throw TranslationError(description: "\(path):\(parser.lineNumber): not well-formed XML")
        }
        self = root
    }

    private init(namespace: String?, localName: String, attributes: [String: String], prefixes: [String: String]) {
        self.namespace = namespace
        self.localName = localName
        self.attributes = attributes
        self.prefixes = prefixes
    }

    private final class Builder: NSObject, XMLParserDelegate {
        var root: SchemaElement?
        private var open: [SchemaElement] = []
        private var scopes: [[String: String]] = [[:]]
        private var pending: [String: String] = [:]

        func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
            pending[prefix] = namespaceURI
        }

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String] = [:]) {
            var scope = scopes[scopes.count - 1]
            scope.merge(pending) { $1 }
            pending = [:]
            // Declarations a parser reports as attributes rather than as
            // prefix mappings.
            for (name, value) in attributes where name == "xmlns" || name.hasPrefix("xmlns:") {
                scope[name == "xmlns" ? "" : String(name.dropFirst(6))] = value
            }
            scopes.append(scope)
            // The name without its prefix: Foundation gives the local name or
            // the qualified one, by platform.
            let name = qualifiedName ?? elementName
            open.append(SchemaElement(
                namespace: namespaceURI.flatMap { $0.isEmpty ? nil : $0 },
                localName: String(name.split(separator: ":").last ?? Substring(name)),
                attributes: attributes,
                prefixes: scope
            ))
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
            guard let element = open.popLast() else { return }
            scopes.removeLast()
            if open.isEmpty {
                root = element
            } else {
                open[open.count - 1].children.append(element)
            }
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            guard !open.isEmpty else { return }
            open[open.count - 1].text += string
        }
    }
}
