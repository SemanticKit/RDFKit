import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Builds a namespace-aware XML tree for RDF/XML decoding.
final class XMLTreeBuilder: NSObject, XMLParserDelegate {
    private var root: XMLElement?
    private var stack: [XMLElement] = []
    private var namespaceStack: [[String: String]] = [
        [
            "xml": "http://www.w3.org/XML/1998/namespace",
            "xmlns": "http://www.w3.org/2000/xmlns/"
        ]
    ]
    private var pendingNamespaceMappings: [String: String] = [:]
    private(set) var parseError: Error?

    /// Records a namespace mapping announced by the XML parser.
    func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
        let key = prefix.isEmpty ? "" : prefix
        pendingNamespaceMappings[key] = namespaceURI
    }

    /// Captures an element start event.
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let mapping = mergedNamespaces()
        namespaceStack.append(mapping)
        pendingNamespaceMappings.removeAll()

        let (prefix, localName) = splitQName(qName ?? elementName)
        let attributes = attributeDict.map { key, value -> XMLAttribute in
            let (attrPrefix, attrLocal) = splitQName(key)
            let attrNamespace = attrPrefix.flatMap { mapping[$0] }
            return XMLAttribute(localName: attrLocal, prefix: attrPrefix, namespaceURI: attrNamespace, value: value)
        }

        let element = XMLElement(localName: localName, prefix: prefix, namespaceURI: namespaceURI, attributes: attributes)
        if let current = stack.last {
            current.children.append(.element(element))
        } else {
            root = element
        }
        stack.append(element)
    }

    /// Captures character data.
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let current = stack.last else { return }
        current.children.append(.text(string))
    }

    /// Captures an element end event.
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        _ = stack.popLast()
        _ = namespaceStack.popLast()
    }

    /// Captures parser errors.
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }

    /// Captures validation errors.
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        self.parseError = validationError
    }

    /// Builds the root element from XML data.
    func buildRoot(from data: Data) throws -> XMLElement {
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true
        parser.delegate = self
        parser.parse()
        if let error = parseError ?? parser.parserError {
            throw error
        }
        guard let root else {
            throw RDFXMLError.invalidDocument("No document element.")
        }
        return root
    }

    private func mergedNamespaces() -> [String: String] {
        var result = namespaceStack.last ?? [:]
        for (key, value) in pendingNamespaceMappings {
            result[key] = value
        }
        return result
    }

    private func splitQName(_ name: String) -> (String?, String) {
        if let index = name.firstIndex(of: ":") {
            let prefix = String(name[..<index])
            let local = String(name[name.index(after: index)...])
            return (prefix, local)
        }
        return (nil, name)
    }
}
