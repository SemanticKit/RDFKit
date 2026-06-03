import Foundation

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

/// A term with OWL deprecation metadata declared by ontology content.
public protocol DeprecatedTerm: Term {
    /// Whether this term is declared owl:deprecated.
    static var deprecated: Bool { get }
}
