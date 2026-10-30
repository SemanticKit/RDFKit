import IRIKit
import RDFCore

// The terms of RDF 1.2 XML Syntax, each made by an initializer on its own
// type from the event that carries it and the element event's scope.
// ``RDFXMLParser`` matches the grammar's productions and emits their
// triples; the terms read themselves.

extension SyntaxError {
    /// A syntax error at the start of `element`.
    init(_ message: String, at element: XMLInfoset.Element) {
        self.init(line: element.line, column: element.column, message: message)
    }
}

extension IRI {
    /// The IRI of an element or attribute event: its namespace name and
    /// local name, which must together be an IRI.
    init(rdfXMLName name: String, at element: XMLInfoset.Element) throws {
        guard let iri = IRI(rawValue: name) else {
            throw SyntaxError("<\(name)> is not an IRI", at: element)
        }
        self = iri
    }

    /// The IRI an `rdf:about`, `rdf:resource`, `rdf:datatype` or
    /// `rdf:annotation` value, or an `rdf:type` property attribute, denotes:
    /// resolved against the in-scope base (Resolving IRIs), as
    /// ``init(reference:base:)`` resolves every reference a document writes.
    init(rdfXMLReference reference: String, scope: RDFXMLParser.Scope, at element: XMLInfoset.Element) throws {
        do {
            self = try IRI(reference: reference, base: scope.base)
        } catch .relativeWithoutBase {
            throw SyntaxError("<\(reference)> is relative and there is no base IRI", at: element)
        } catch .unresolvable(let base) {
            throw SyntaxError("<\(reference)> does not resolve to an IRI against <\(base)>", at: element)
        }
    }

    /// The IRI of an `rdf:ID` value (production idAttr): `#` and the value,
    /// resolved against the in-scope base, and unique in the document
    /// (constraint-id), which `parser` keeps track of.
    init(rdfXMLID id: String, parser: inout RDFXMLParser, scope: RDFXMLParser.Scope, at element: XMLInfoset.Element) throws {
        guard RDFXMLParser.isNCName(id) else {
            throw SyntaxError("rdf:ID \"\(id)\" is not an XML NCName", at: element)
        }
        try self.init(rdfXMLReference: "#" + id, scope: scope, at: element)
        guard parser.identifiers.insert(self).inserted else {
            throw SyntaxError("rdf:ID \"\(id)\" names <\(self)>, which another rdf:ID already names", at: element)
        }
    }
}

extension BlankNode {
    /// The blank node of an `rdf:nodeID` or `rdf:annotationNodeID` value,
    /// the same node for the same value throughout `parser`'s document.
    init(rdfXMLNodeID id: String, parser: inout RDFXMLParser, at element: XMLInfoset.Element) throws {
        guard RDFXMLParser.isNCName(id) else {
            throw SyntaxError("the blank node identifier \"\(id)\" is not an XML NCName", at: element)
        }
        self = try parser.blankNodes.node(labelled: id)
    }
}

extension Literal {
    /// A literal without datatype (Literal Without Datatype Event): the
    /// in-scope language and base direction make it a language-tagged or
    /// directional string.
    init(rdfXMLText value: String, scope: RDFXMLParser.Scope, at element: XMLInfoset.Element) throws {
        guard !scope.language.isEmpty else {
            self.init(value)
            return
        }
        do {
            self = try Literal(value, languageTag: scope.language, baseDirection: BaseDirection(rawValue: scope.direction))
        } catch {
            throw SyntaxError("\(error)", at: element)
        }
    }

    /// A typed literal (Typed Literal Event).
    init(rdfXML value: String, datatype: IRI, at element: XMLInfoset.Element) throws {
        do {
            self = try Literal(value, datatypeIRI: datatype)
        } catch {
            throw SyntaxError("<\(datatype)> cannot be the datatype of \"\(value)\"", at: element)
        }
    }
}
