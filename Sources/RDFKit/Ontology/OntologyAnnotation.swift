import Foundation

/// Groups annotation facts inside an ontology declaration.
public struct Annotation<Body: AnnotationContent>: ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The grouped annotation content.
    let content: Body

    /// Creates an annotation block.
    public init(@AnnotationContentBuilder content: () -> Body) {
        self.content = content()
    }
}

extension Annotation: OntologyFactContent {
    /// Adds this annotation block's facts to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        facts.addFacts(in: content, environment: environment)
    }
}
