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
public protocol TermContent: Node {}

// MARK: - Declaration Protocols

/// An RDF class declaration.
public protocol ClassDeclaration: TermContent {
    /// The declared class name.
    var name: String { get }

    /// The child annotations for this class.
    var children: [any Node] { get }
}

/// An RDF property declaration.
public protocol PropertyDeclaration: TermContent {
    /// The declared property name.
    var name: String { get }

    /// The child annotations for this property.
    var children: [any Node] { get }
}

/// An RDF individual declaration.
public protocol IndividualDeclaration: TermContent {
    /// The declared individual name.
    var name: String { get }

    /// The child annotations for this individual.
    var children: [any Node] { get }
}

/// An RDF datatype declaration.
public protocol DatatypeDeclaration: TermContent {
    /// The declared datatype name.
    var name: String { get }

    /// The child annotations for this datatype.
    var children: [any Node] { get }
}

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
public protocol ContributionAnnotation: TermContent {
    /// The contribution protocol name to add to the generated struct.
    ///
    /// e.g., "TypedTerm", "LabeledTerm", "CommentedTerm"
    var contributionProtocolName: String { get }

    /// The type name for the children initializer expression.
    ///
    /// e.g., "TypeAnnotationValue", "LabelAnnotationValue"
    /// The macro emits: `{contributionTypeName}({argumentText})`
    var contributionTypeName: String { get }
}

// MARK: - Annotation Protocols

/// Assigns an RDF type to a term.
public protocol TypeAnnotation: TermContent {
    /// The type term being assigned.
    var term: any Node { get }
}

/// Declares a superclass relationship.
public protocol SubClassOfAnnotation: TermContent {
    /// The superclass term.
    var term: any Node { get }
}

/// Declares a superproperty relationship.
public protocol SubPropertyOfAnnotation: TermContent {
    /// The superproperty term.
    var term: any Node { get }
}

/// Declares the domain of a property.
public protocol DomainAnnotation: TermContent {
    /// The domain term.
    var term: any Node { get }
}

/// Declares the range of a property.
public protocol RangeAnnotation: TermContent {
    /// The range term.
    var term: any Node { get }
}

/// A human-readable label.
public protocol LabelProtocol: TermContent {
    /// The label text.
    var text: String { get }
}

/// A descriptive comment.
public protocol CommentProtocol: TermContent {
    /// The comment text.
    var text: String { get }
}

/// A reference to related information.
public protocol SeeAlsoProtocol: TermContent {
    /// The reference URL.
    var url: String { get }
}

/// Marks a term as deprecated.
public protocol OWLDeprecatedProtocol: TermContent {}

/// Declares which ontology namespace a term belongs to.
///
/// When absent or set to `nil`, the term belongs to the parent ontology.
/// When set to a different namespace, the term is imported from that ontology.
public protocol IsDeclaredByProtocol: TermContent {
    /// The namespace the term is declared in, or `nil` for the parent ontology.
    var namespace: Namespace? { get }
}

// MARK: - Concrete Declaration Type

/// A concrete RDF term declaration.
///
/// `TermDeclaration` conforms to all declaration protocols, providing
/// a single reusable type for class, property, individual, and datatype
/// declarations.
public struct TermDeclaration: ClassDeclaration, PropertyDeclaration,
    IndividualDeclaration, DatatypeDeclaration
{
    public let name: String
    public let children: [any Node]

    public init(name: String, children: [any Node]) {
        self.name = name
        self.children = children
    }
}

// MARK: - Concrete Annotation Types

/// Assigns an RDF type to a term.
public struct TypeAnnotationValue: TypeAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "TypedTerm"
    public let contributionTypeName: String = "TypeAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

/// Declares a superclass relationship.
public struct SubClassOfAnnotationValue: SubClassOfAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "SubClassedTerm"
    public let contributionTypeName: String = "SubClassOfAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

/// Declares a superproperty relationship.
public struct SubPropertyOfAnnotationValue: SubPropertyOfAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "SubPropertyOfTerm"
    public let contributionTypeName: String = "SubPropertyOfAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

/// Declares the domain of a property.
public struct DomainAnnotationValue: DomainAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "DomainTerm"
    public let contributionTypeName: String = "DomainAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

/// Declares the range of a property.
public struct RangeAnnotationValue: RangeAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "RangeTerm"
    public let contributionTypeName: String = "RangeAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

/// A human-readable label.
public struct LabelAnnotationValue: LabelProtocol, ContributionAnnotation {
    public let text: String
    public let contributionProtocolName: String = "LabeledTerm"
    public let contributionTypeName: String = "LabelAnnotationValue"

    public init(_ text: String) {
        self.text = text
    }
}

/// A descriptive comment.
public struct CommentAnnotationValue: CommentProtocol, ContributionAnnotation {
    public let text: String
    public let contributionProtocolName: String = "CommentedTerm"
    public let contributionTypeName: String = "CommentAnnotationValue"

    public init(_ text: String) {
        self.text = text
    }
}

/// A reference to related information.
public struct SeeAlsoAnnotationValue: SeeAlsoProtocol, ContributionAnnotation {
    public let url: String
    public let contributionProtocolName: String = "SeeAlsoTerm"
    public let contributionTypeName: String = "SeeAlsoAnnotationValue"

    public init(_ url: String) {
        self.url = url
    }
}

/// Marks a term as deprecated.
public struct OWLDeprecatedAnnotationValue: OWLDeprecatedProtocol, ContributionAnnotation {
    public let contributionProtocolName: String = "DeprecatedTerm"
    public let contributionTypeName: String = "OWLDeprecatedAnnotationValue"

    public init() {}
}

/// Declares which ontology namespace a term belongs to.
///
/// When `namespace` is `nil`, the term belongs to the parent ontology.
/// When set to a different namespace, the term is imported from that ontology.
public struct IsDeclaredByAnnotation: IsDeclaredByProtocol, ContributionAnnotation {
    public let namespace: Namespace?
    public let contributionProtocolName: String = "DeclaredByTerm"
    public let contributionTypeName: String = "IsDeclaredByAnnotation"

    public init(_ namespace: Namespace?) {
        self.namespace = namespace
    }
}

// MARK: - DSL Entry Points: Declarations

/// Declares an RDF class.
///
///     Class("Resource") {
///         Type(RDFS.Class)
///         Label("Resource")
///         Comment("The class resource, everything.")
///     }
public func Class(
    _ name: String,
    @TermContentBuilder children: () -> [any Node]
) -> TermDeclaration {
    TermDeclaration(name: name, children: children())
}

/// Declares an RDF property.
///
///     Property("label") {
///         Type(RDF.Property)
///         Domain(RDFS.Resource)
///         Range(RDFS.Literal)
///         Label("label")
///     }
public func Property(
    _ name: String,
    @TermContentBuilder children: () -> [any Node]
) -> TermDeclaration {
    TermDeclaration(name: name, children: children())
}

/// Declares an RDF individual.
///
///     Individual("nil") {
///         Type(RDF.List)
///         Label("nil")
///     }
public func Individual(
    _ name: String,
    @TermContentBuilder children: () -> [any Node]
) -> TermDeclaration {
    TermDeclaration(name: name, children: children())
}

/// Declares an RDF datatype.
///
///     Datatype("langString") {
///         Type(RDFS.Datatype)
///         SubClassOf(RDFS.Literal)
///         Label("langString")
///     }
public func Datatype(
    _ name: String,
    @TermContentBuilder children: () -> [any Node]
) -> TermDeclaration {
    TermDeclaration(name: name, children: children())
}

// MARK: - DSL Entry Points: Term Reference Annotations

/// Assigns an RDF type to a term.
///
///     Type(RDFS.Class)
///     Type(RDF.Property)
public func Type(_ term: any Node) -> TypeAnnotationValue {
    TypeAnnotationValue(term)
}

/// Declares a superclass relationship.
///
///     SubClassOf(RDFS.Resource)
public func SubClassOf(_ term: any Node) -> SubClassOfAnnotationValue {
    SubClassOfAnnotationValue(term)
}

/// Declares a superproperty relationship.
///
///     SubPropertyOf(RDFS.SeeAlso)
public func SubPropertyOf(_ term: any Node) -> SubPropertyOfAnnotationValue {
    SubPropertyOfAnnotationValue(term)
}

/// Declares the domain of a property.
///
///     Domain(RDFS.Resource)
public func Domain(_ term: any Node) -> DomainAnnotationValue {
    DomainAnnotationValue(term)
}

/// Declares the range of a property.
///
///     Range(RDFS.Literal)
public func Range(_ term: any Node) -> RangeAnnotationValue {
    RangeAnnotationValue(term)
}

// MARK: - DSL Entry Points: String Annotations

/// A human-readable label for a term.
///
///     Label("Resource")
public func Label(_ text: String) -> LabelAnnotationValue {
    LabelAnnotationValue(text)
}

/// A descriptive comment for a term.
///
///     Comment("The class resource, everything.")
public func Comment(_ text: String) -> CommentAnnotationValue {
    CommentAnnotationValue(text)
}

/// A reference to related information.
///
///     SeeAlso("https://www.w3.org/TR/rdf12-concepts/")
public func SeeAlso(_ url: String) -> SeeAlsoAnnotationValue {
    SeeAlsoAnnotationValue(url)
}

// MARK: - DSL Entry Points: Flag Annotations

/// Marks a term as deprecated in OWL.
///
///     OWLDeprecated()
public func OWLDeprecated() -> OWLDeprecatedAnnotationValue {
    OWLDeprecatedAnnotationValue()
}

// MARK: - Term Declaration Modifiers
//
// Domain-specific convenience methods on TermDeclaration.
// These replace the generic `.modifier(DeprecatedModifier())` pattern
// with idiomatic DSL syntax: `.deprecated()`, `.typed(...)`, etc.

extension TermDeclaration {

    /// Marks this term as deprecated.
    ///
    ///     Class("PlainLiteral") {
    ///         Type(RDFSTerm.Datatype)
    ///         Label("PlainLiteral")
    ///     }.deprecated()
    public func deprecated() -> TermDeclaration {
        TermDeclaration(
            name: name,
            children: children + [OWLDeprecatedAnnotationValue()]
        )
    }

    /// Declares which ontology namespace this term belongs to.
    ///
    /// Without this modifier, the term automatically belongs to the parent ontology.
    /// When passed a different namespace, the term is imported from that ontology.
    ///
    ///     Class("Thing") {
    ///         Type(OWL.Class)
    ///         Label("Thing")
    ///     }.isDeclaredBy(namespace: OWL.namespace)
    public func isDeclaredBy(namespace: Namespace? = nil) -> TermDeclaration {
        TermDeclaration(
            name: name,
            children: children + [IsDeclaredByAnnotation(namespace)]
        )
    }
}
