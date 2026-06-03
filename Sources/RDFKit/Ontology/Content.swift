import Foundation

/// General ontology DSL content.
public protocol Content: Sendable {}

/// Top-level ontology content.
public protocol OntologyContent: Content {}

/// Content accepted by class declarations.
public protocol ClassContent: Content {}

/// Content accepted by property declarations.
public protocol PropertyContent: Content {}

/// Content accepted by datatype declarations.
public protocol DatatypeContent: Content {}

/// Content accepted by individual declarations.
public protocol IndividualContent: Content {}

/// Content accepted by annotation declarations.
public protocol AnnotationContent: Content {}

/// A DSL declaration role resolved inside an ontology namespace.
enum OntologyDeclarationRole: Equatable, Sendable {
    case `class`
    case property
    case datatype
    case individual
}

/// Content whose term identity is scoped by the enclosing ontology namespace.
protocol NamespaceScopedDeclaration: OntologyTermContent, OntologyDeclarationFactContent, OntologyExpansionContent {
    /// The declaration role.
    var role: OntologyDeclarationRole { get }

    /// The local name declared inside the enclosing ontology namespace.
    var localName: LocalName { get }

    /// The declaration body content.
    var bodyContent: any Content { get }
}

extension NamespaceScopedDeclaration {
    /// Returns the declaration IRI inside an ontology environment.
    func iri(in environment: OntologyEnvironment) -> IRI {
        QualifiedName(namespace: environment.namespace, localName: localName).iri
    }
}

extension NamespaceScopedDeclaration {
    /// Returns the scoped declaration IRI when it matches the requested role.
    func termIRIs(in environment: OntologyEnvironment, role requestedRole: OntologyDeclarationRole?) throws -> [IRI] {
        guard requestedRole == nil || role == requestedRole else {
            return []
        }

        return [iri(in: environment)]
    }

    /// Adds this scoped declaration's facts to the declaration fact map.
    func addDeclarationFacts(to facts: inout [IRI: OntologyDeclarationFacts], in environment: OntologyEnvironment) {
        facts[iri(in: environment)] = ContentFactResolver.declarationFacts(in: bodyContent, environment: environment)
    }
}

/// Empty DSL content.
public struct EmptyContent: OntologyContent, ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// Creates empty content.
    public init() {}
}

/// A group of DSL content values.
public struct ContentGroup: OntologyContent, ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The grouped content values.
    public let elements: [any Content]

    /// Creates a content group.
    public init(_ elements: [any Content]) {
        self.elements = elements
    }
}

extension ContentGroup: OntologyNamespaceContent {
    /// The namespace declarations contributed by grouped content.
    var declaredNamespaces: [Namespace] {
        var namespaces: [Namespace] = []

        for element in elements {
            if let namespaceContent = element as? any OntologyNamespaceContent {
                namespaces.append(contentsOf: namespaceContent.declaredNamespaces)
            }
        }

        return namespaces
    }
}

extension ContentGroup: OntologyTermContent {
    /// Returns term IRIs contributed by grouped content.
    func termIRIs(in environment: OntologyEnvironment, role: OntologyDeclarationRole?) throws -> [IRI] {
        var iris: [IRI] = []

        for element in elements {
            if let termContent = element as? any OntologyTermContent {
                iris.append(contentsOf: try termContent.termIRIs(in: environment, role: role))
            }
        }

        return iris
    }
}

extension ContentGroup: OntologyFactContent {
    /// Adds declaration facts contributed by grouped content.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        for element in elements {
            if let factContent = element as? any OntologyFactContent {
                factContent.addFacts(to: &facts, in: environment)
            }
        }
    }
}

extension ContentGroup: OntologyDeclarationFactContent {
    /// Adds declaration facts contributed by grouped content.
    func addDeclarationFacts(to facts: inout [IRI: OntologyDeclarationFacts], in environment: OntologyEnvironment) {
        for element in elements {
            if let declarationContent = element as? any OntologyDeclarationFactContent {
                declarationContent.addDeclarationFacts(to: &facts, in: environment)
            }
        }
    }
}

/// Builds protocol-based ontology content.
@resultBuilder
public enum ContentBuilder {
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    public static func buildBlock<ContentValue: Content>(_ content: ContentValue) -> ContentValue {
        content
    }

    public static func buildBlock(_ content: any Content...) -> ContentGroup {
        ContentGroup(content)
    }
}
