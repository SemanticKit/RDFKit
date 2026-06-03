import Foundation

/// Encodes RDF graphs into RDF/XML source.
struct RDFXMLEncoder {
    private let baseIRI: IRI?
    private let rdfNamespace = RDF.namespace.rawValue
    private let itsNamespace = "http://www.w3.org/2005/11/its"

    /// Creates an RDF/XML graph encoder.
    init(baseIRI: IRI?) {
        self.baseIRI = baseIRI
    }

    /// Encodes a graph as RDF/XML source.
    func encode(graph: Graph) -> String {
        let subjects = Dictionary(grouping: graph.triples, by: { $0.subject })
        let namespaceMap = buildNamespaceMap(for: graph.triples)
        let needsITS = graph.triples.contains { triple in
            if let literal = triple.object.node as? Literal {
                return literal.textDirection != nil
            }
            return false
        }

        var xmlns = "xmlns:rdf=\"\(rdfNamespace)\""
        for (prefix, namespace) in namespaceMap.sorted(by: { $0.key < $1.key }) {
            xmlns += " xmlns:\(prefix)=\"\(namespace)\""
        }
        if needsITS {
            xmlns += " xmlns:its=\"\(itsNamespace)\""
        }
        if let baseIRI {
            xmlns += " xml:base=\"\(baseIRI.string)\""
        }

        var lines: [String] = []
        lines.append("<rdf:RDF \(xmlns)>")
        for (subject, triples) in subjects.sorted(by: { $0.key.description < $1.key.description }) {
            lines.append(encodeSubject(subject, triples: triples, namespaceMap: namespaceMap))
        }
        lines.append("</rdf:RDF>")
        return lines.joined(separator: "\n")
    }

    private func encodeSubject(_ subject: AnyRDFSubject, triples: [Graph.TripleType], namespaceMap: [String: String]) -> String {
        var lines: [String] = []
        let subjectAttributes: String
        if let iri = subject.node as? IRI {
            subjectAttributes = " rdf:about=\"\(iri.string)\""
        } else if let blank = subject.node as? BlankNode {
            subjectAttributes = " rdf:nodeID=\"\(blank.identifier)\""
        } else {
            subjectAttributes = ""
        }
        lines.append("  <rdf:Description\(subjectAttributes)>")
        for triple in triples.sorted(by: { $0.predicate.string < $1.predicate.string }) {
            lines.append(encodePredicateObject(triple.predicate, triple.object, namespaceMap: namespaceMap))
        }
        lines.append("  </rdf:Description>")
        return lines.joined(separator: "\n")
    }

    private func encodePredicateObject(_ predicate: IRI, _ object: AnyRDFObject, namespaceMap: [String: String]) -> String {
        if let tripleTerm = object.node as? TripleTerm {
            return encodeTripleTerm(predicate, tripleTerm, namespaceMap: namespaceMap)
        }

        let qname = qnameFor(predicate, namespaceMap: namespaceMap) ?? "rdf:Description"
        if let iri = object.node as? IRI {
            return "    <\(qname) rdf:resource=\"\(iri.string)\"/>"
        }
        if let blank = object.node as? BlankNode {
            return "    <\(qname) rdf:nodeID=\"\(blank.identifier)\"/>"
        }
        if let literal = object.node as? Literal {
            var attrs: [String] = []
            if let language = literal.languageTag {
                attrs.append("xml:lang=\"\(language)\"")
                if let direction = literal.textDirection {
                    attrs.append("its:dir=\"\(direction.rawValue)\"")
                }
            } else if let datatype = literal.datatype {
                attrs.append("rdf:datatype=\"\(datatype.string)\"")
            }
            let attrString = attrs.isEmpty ? "" : " " + attrs.joined(separator: " ")
            let value = escapeText(literal.lexicalForm)
            return "    <\(qname)\(attrString)>\(value)</\(qname)>"
        }
        return "    <\(qname)/>"
    }

    private func encodeTripleTerm(_ predicate: IRI, _ tripleTerm: TripleTerm, namespaceMap: [String: String]) -> String {
        let qname = qnameFor(predicate, namespaceMap: namespaceMap) ?? "rdf:Description"
        var lines: [String] = []
        lines.append("    <\(qname) rdf:parseType=\"Triple\">")
        lines.append("      \(encodeTripleTermSubject(tripleTerm, namespaceMap: namespaceMap))")
        lines.append("    </\(qname)>")
        return lines.joined(separator: "\n")
    }

    private func encodeTripleTermSubject(_ tripleTerm: TripleTerm, namespaceMap: [String: String]) -> String {
        let subject = tripleTerm.subject
        let subjectAttributes: String
        if let iri = subject.node as? IRI {
            subjectAttributes = " rdf:about=\"\(iri.string)\""
        } else if let blank = subject.node as? BlankNode {
            subjectAttributes = " rdf:nodeID=\"\(blank.identifier)\""
        } else {
            subjectAttributes = ""
        }
        let predicateLine = encodePredicateObject(tripleTerm.predicate, tripleTerm.object, namespaceMap: namespaceMap)
        let indentedPredicate = predicateLine.replacingOccurrences(of: "    ", with: "        ")
        return "<rdf:Description\(subjectAttributes)>\n\(indentedPredicate)\n      </rdf:Description>"
    }

    private func buildNamespaceMap(for triples: Set<Graph.TripleType>) -> [String: String] {
        var namespaces: [String: String] = [:]
        var counter = 1
        for triple in triples {
            let predicate = triple.predicate
            if let (namespace, _) = splitIRI(predicate.string) {
                if namespaces.values.contains(namespace) { continue }
                let prefix = "ns\(counter)"
                namespaces[prefix] = namespace
                counter += 1
            }
        }
        return namespaces
    }

    private func qnameFor(_ iri: IRI, namespaceMap: [String: String]) -> String? {
        guard let (namespace, local) = splitIRI(iri.string) else { return nil }
        guard let prefix = namespaceMap.first(where: { $0.value == namespace })?.key else { return nil }
        return "\(prefix):\(local)"
    }

    private func splitIRI(_ iri: String) -> (String, String)? {
        if let hashIndex = iri.lastIndex(of: "#") {
            let ns = String(iri[..<iri.index(after: hashIndex)])
            let local = String(iri[iri.index(after: hashIndex)...])
            return validateLocalName(local) ? (ns, local) : nil
        }
        if let slashIndex = iri.lastIndex(of: "/") {
            let ns = String(iri[..<iri.index(after: slashIndex)])
            let local = String(iri[iri.index(after: slashIndex)...])
            return validateLocalName(local) ? (ns, local) : nil
        }
        return nil
    }

    private func validateLocalName(_ value: String) -> Bool {
        guard let first = value.unicodeScalars.first else { return false }
        if !(CharacterSet.letters.union(CharacterSet(charactersIn: "_")).contains(first)) {
            return false
        }
        let allowed = CharacterSet.letters.union(CharacterSet.decimalDigits).union(CharacterSet(charactersIn: "._-"))
        return value.unicodeScalars.dropFirst().allSatisfy { allowed.contains($0) }
    }

    private func escapeText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
