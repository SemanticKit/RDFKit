import Foundation

/// Content that reads the enclosing ontology environment during DSL evaluation.
public struct Environment<Body: Content>: OntologyContent, ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    private let buildContent: @Sendable (OntologyEnvironment) -> Body

    /// Creates environment-aware content.
    public init(@ContentBuilder _ content: @escaping @Sendable (OntologyEnvironment) -> Body) {
        self.buildContent = content
    }
}

/// Content that can be resolved against an ontology environment.
protocol EnvironmentResolvedContent: Content {
    /// Resolves this content inside an ontology environment.
    func resolve(in environment: OntologyEnvironment) -> any Content
}

extension Environment: EnvironmentResolvedContent {
    /// Resolves the environment-aware content.
    func resolve(in environment: OntologyEnvironment) -> any Content {
        buildContent(environment)
    }
}
