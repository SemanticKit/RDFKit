/// A generated role that binds a direct DSL identifier to an ontology term.
public protocol DeclaredOntologyTerm: Sendable {
    /// The term name exactly as authored in the ontology declaration.
    static var ontologyTermName: String { get }
}

/// Authored content whose generic role is generated from an ontology term.
public protocol DeclaredOntologyTermContent: Content {
    /// The generated role that identifies the authored ontology term.
    associatedtype DeclaredTerm: DeclaredOntologyTerm
}

extension NamedDeclaration: DeclaredOntologyTermContent where Role: DeclaredOntologyTerm {
    /// The generated role that identifies the authored ontology term.
    public typealias DeclaredTerm = Role
}
