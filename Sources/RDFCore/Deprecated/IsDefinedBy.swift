import Foundation

// MARK: - Protocol

/// Declares which ontology namespace a term belongs to.
///
/// From RDFS: Used to indicate a resource defining the subject resource.
/// Domain: rdfs:Resource, range: rdfs:Resource. Subproperty of rdfs:seeAlso.
//public protocol IsDeclaredByProtocol: TermContent {
//    /// The namespace the term is declared in, or `nil` for the parent ontology.
//    var namespace: Namespace? { get }
//}

// MARK: - Concrete Type

/// Declares which ontology namespace a term belongs to.
//public struct IsDeclaredByAnnotation: IsDeclaredByProtocol, ContributionAnnotation {
//    public let namespace: Namespace?
//    public let contributionProtocolName: String = "DeclaredByTerm"
//    public let contributionTypeName: String = "IsDeclaredByAnnotation"
//
//    public init(_ namespace: Namespace?) {
//        self.namespace = namespace
//    }
//}

// MARK: - DSL

/// Declares which ontology namespace this term belongs to.
///
/// Without this modifier, the term automatically belongs to the parent ontology.
/// When passed a different namespace, the term is imported from that ontology.
///
///     Class("Thing") {
///         Type(OWL.Class)
///         Label("Thing")
///     }.isDeclaredBy(namespace: OWL.namespace)
//public func isDeclaredBy(namespace: Namespace? = nil) -> IsDeclaredByAnnotation {
//    IsDeclaredByAnnotation(namespace)
//}
