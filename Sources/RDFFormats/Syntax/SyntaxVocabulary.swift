import IRIKit

extension IRI {
    // The IRIs the grammars of the formats fix: Turtle's `a` (RDF 1.2 Turtle
    // §2.4), its collections and numeric and boolean literals (§2.5, §2.6),
    // its reified triples (§2.8), and RDF/XML's `rdf:parseType`
    // productions and reification (RDF 1.2 XML Syntax §2.16-§2.17). They are
    // part of each syntax, read and written only here, at the boundary.
    //
    // Recorded exception, raised to Charles as a decision (RDFKit #14 fix
    // round 1, Rule 0): these, and RDFXMLParser's RDF and ITS namespaces and
    // syntax-term lists, are typed here rather than taken from rdf.ttl or the
    // grammars' spec text. RDFFormats is what decodes rdf.ttl (the RDF
    // module is translated from it by RDFTranslator, which depends on
    // RDFFormats), so RDFFormats cannot take them from the translated RDF
    // module without a cycle, and the grammars' own text arrives with the
    // EBNF work (WP-EBNF), which is out of scope for #14. Options: (A) the
    // EBNF work generates them from each grammar's spec text with the
    // productions; (B) RDFFormats reads rdf.ttl itself at run time, with a
    // Turtle reading of `a`, collections and literals bootstrapped from the
    // Turtle spec text; (C) keep them here as the syntax's own constants.
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
    // The datatype IRIs RDF 1.2 Concepts §3.4 ties to a literal's form: a
    // simple literal's, a language-tagged string's and a directional one's.
    static let xsdString: IRI = "http://www.w3.org/2001/XMLSchema#string"
    static let rdfLangString: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"
    static let rdfDirLangString: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString"
}
