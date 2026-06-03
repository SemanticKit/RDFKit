import Foundation

/// A term with RDF type declarations.
public protocol TypedTerm: Term {
    /// The rdf:type values declared for this term.
    static var types: [IRI] { get }
}

/// A term with RDFS superclass declarations.
public protocol SubclassAwareTerm: Term {
    /// The rdfs:subClassOf values declared for this term.
    static var superclasses: [IRI] { get }
}

/// A term with RDFS labels declared by ontology content.
public protocol LabeledTerm: Term {
    /// The rdfs:label values declared for this term.
    static var labels: [String] { get }
}

/// A term with RDFS comments declared by ontology content.
public protocol CommentedTerm: Term {
    /// The rdfs:comment values declared for this term.
    static var comments: [String] { get }
}

/// A term with RDFS see-also declarations.
public protocol SeeAlsoTerm: Term {
    /// The rdfs:seeAlso values declared for this term.
    static var seeAlso: [IRI] { get }
}

/// A term with RDFS definition-source declarations.
public protocol IsDefinedByTerm: Term {
    /// The rdfs:isDefinedBy values declared for this term.
    static var isDefinedBy: [IRI] { get }
}

/// A term with OWL deprecation metadata declared by ontology content.
public protocol DeprecatedTerm: Term {
    /// Whether this term is declared owl:deprecated.
    static var deprecated: Bool { get }
}
