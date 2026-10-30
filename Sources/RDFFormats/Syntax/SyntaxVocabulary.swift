import IRIKit

extension IRI {
    // The IRIs the grammars of the formats fix: Turtle's `a` (RDF 1.2 Turtle
    // §2.4), its collections and numeric and boolean literals (§2.5, §2.6),
    // its reified triples (§2.8), and RDF/XML's `rdf:parseType`
    // productions and reification (RDF 1.2 XML Syntax §2.16-§2.17). They are
    // part of each syntax, read and written only here, at the boundary.
    static let rdfType: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
    static let rdfFirst: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#first"
    static let rdfRest: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest"
    static let rdfNil: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"
    static let rdfReifies: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies"
    static let rdfSubject: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#subject"
    static let rdfPredicate: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate"
    static let rdfObject: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#object"
    static let rdfStatement: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement"
    static let rdfXMLLiteral: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"
    static let xsdInteger: IRI = "http://www.w3.org/2001/XMLSchema#integer"
    static let xsdDecimal: IRI = "http://www.w3.org/2001/XMLSchema#decimal"
    static let xsdDouble: IRI = "http://www.w3.org/2001/XMLSchema#double"
    static let xsdBoolean: IRI = "http://www.w3.org/2001/XMLSchema#boolean"
}
