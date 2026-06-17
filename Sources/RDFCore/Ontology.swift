import Foundation

/// The type returned by an ontology's `content` property.
///
/// Content is an ordered list of RDF nodes — declarations (classes, properties,
/// individuals, datatypes), prefixes, and namespaces — that together define an
/// ontology's vocabulary.
public typealias Content = [any Node]

/// A declaratively authored ontology.
public protocol Ontology: Sendable, Namespaced {
    /// The authored ontology content.
    @ContentBuilder var content: Content { get }
}

extension Ontology {

    /// The namespace extracted from this ontology's content tree.
    ///
    /// Walks the content to find the first `Namespace` node. Every ontology
    /// gets this automatically — no manual implementation needed.
    public var namespace: Namespace {
        for node in content {
            if let ns = node as? Namespace {
                return ns
            }
        }
        preconditionFailure("Expected a Namespace declaration in content.")
    }

    /// An IRI resolver that can resolve term names to full IRIs
    /// using this ontology's namespace.
    ///
    ///     let resolver = OWL().iriResolver
    ///     let classIRI = resolver.resolve("Class")
    public var iriResolver: IRIResolver {
        IRIResolver(namespace)
    }
}

// MARK: - DSL Declaration Methods

extension Ontology {

    /// Declares an RDF class.
    func `Class`(_ name: String, @TermContentBuilder children: () -> [any Node]) -> TermDeclaration {
        TermDeclaration(kind: .class, name: name, children: children())
    }

    /// Declares an RDF property.
    func Property(_ name: String, @TermContentBuilder children: () -> [any Node]) -> TermDeclaration {
        TermDeclaration(kind: .property, name: name, children: children())
    }

    /// Declares an RDF individual.
    func Individual(_ name: String, @TermContentBuilder children: () -> [any Node]) -> TermDeclaration {
        TermDeclaration(kind: .individual, name: name, children: children())
    }

    /// Declares an RDF datatype.
    func Datatype(_ name: String, @TermContentBuilder children: () -> [any Node]) -> TermDeclaration {
        TermDeclaration(kind: .datatype, name: name, children: children())
    }
}

// MARK: - DSL Annotation Methods

extension Ontology {

    /// Assigns an RDF type to a term.
    func Type(_ term: any Node) -> TypeAnnotationValue {
        TypeAnnotationValue(term)
    }

    /// Declares a superclass relationship.
    func SubClassOf(_ term: any Node) -> SubClassOfAnnotationValue {
        SubClassOfAnnotationValue(term)
    }

    /// Declares a superproperty relationship.
    func SubPropertyOf(_ term: any Node) -> SubPropertyOfAnnotationValue {
        SubPropertyOfAnnotationValue(term)
    }

    /// Declares the domain of a property.
    func Domain(_ term: any Node) -> DomainAnnotationValue {
        DomainAnnotationValue(term)
    }

    /// Declares the range of a property.
    func Range(_ term: any Node) -> RangeAnnotationValue {
        RangeAnnotationValue(term)
    }

    /// A human-readable label for a term.
    func Label(_ text: String) -> LabelAnnotationValue {
        LabelAnnotationValue(text)
    }

    /// A descriptive comment for a term.
    func Comment(_ text: String) -> CommentAnnotationValue {
        CommentAnnotationValue(text)
    }

    /// A reference to related information.
    func SeeAlso(_ url: String) -> SeeAlsoAnnotationValue {
        SeeAlsoAnnotationValue(url)
    }

    /// Marks a term as deprecated in OWL.
    func OWLDeprecated() -> OWLDeprecatedAnnotationValue {
        OWLDeprecatedAnnotationValue()
    }
}
