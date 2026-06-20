import Foundation

// MARK: - Term Content Protocol

/// A type that can appear as child content within a term declaration.
///
/// Extend this protocol to create custom vocabulary types for use in
/// the RDF ontology DSL. Any type conforming to `TermContent` works
/// automatically with `@ContentBuilder`.
///
///     public struct MyAnnotation: TermContent, Sendable {
///         public let value: String
///     }
///
///     public func MyAnnotation(_ value: String) -> any Node {
///         MyAnnotation(value: value)
///     }
//public protocol TermContent: Node {}

// MARK: - Code Generation Protocol

/// Drives code generation from the DSL side.
///
/// Each annotation value type conforms to this protocol and provides
/// the behavior the macro needs — what contribution protocol to add
/// to the generated struct, and what type name to use in children
/// initializer expressions.
///
/// Adding a new annotation type = create a struct conforming to this
/// protocol, write a free function returning it. Zero macro changes.
//public protocol ContributionAnnotation: TermContent {
//    /// The contribution protocol name to add to the generated struct.
//    ///
//    /// e.g., "TypedTerm", "LabeledTerm", "CommentedTerm"
//    var contributionProtocolName: String { get }
//
//    /// The type name for the children initializer expression.
//    ///
//    /// e.g., "TypeAnnotationValue", "LabelAnnotationValue"
//    /// The macro emits: `{contributionTypeName}({argumentText})`
//    var contributionTypeName: String { get }
//}

// MARK: - Concrete Declaration Type

/// A concrete RDF term declaration.
///
/// `TermDeclaration` conforms to all declaration protocols, providing
/// a single reusable type for class, property, individual, and datatype
/// declarations.
//public struct TermDeclaration: ClassDeclaration, PropertyDeclaration,
//    IndividualDeclaration, DatatypeDeclaration, Node
//{
//    public let name: String
//    public var children: [any Node]
//
//    public init(name: String, children: [any Node] = []) {
//        self.name = name
//        self.children = children
//    }
//}

// MARK: - Term Declaration Modifiers

//extension TermDeclaration {
//
//    /// Marks this term as deprecated.
//    ///
//    ///     Class("PlainLiteral") {
//    ///         Type(RDFSTerm.Datatype)
//    ///         Label("PlainLiteral")
//    ///     }.deprecated()
//    public func deprecated() -> TermDeclaration {
//        TermDeclaration(
//            name: name,
//            children: children + [OWLDeprecatedAnnotationValue()]
//        )
//    }
//
//    /// Declares which ontology namespace this term belongs to.
//    ///
//    /// Without this modifier, the term automatically belongs to the parent ontology.
//    /// When passed a different namespace, the term is imported from that ontology.
//    ///
//    ///     Class("Thing") {
//    ///         Type(OWL.Class)
//    ///         Label("Thing")
//    ///     }.isDeclaredBy(namespace: OWL.namespace)
//    public func isDeclaredBy(namespace: Namespace? = nil) -> TermDeclaration {
//        TermDeclaration(
//            name: name,
//            children: children + [IsDeclaredByAnnotation(namespace)]
//        )
//    }
//}
