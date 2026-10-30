import SwiftDiagnostics

/// A diagnostic the ontology macros report at the authored line it is about.
struct OntologyDiagnostic: DiagnosticMessage {
    let message: String
    let id: String
    let severity: DiagnosticSeverity = .error

    var diagnosticID: MessageID { MessageID(domain: "RDFKitMacros", id: id) }

    /// A term annotation written with a generic argument or a `.self` argument.
    static func writeRelatedTypeAsArgument(form: String, type: String) -> Self {
        Self(message: "Write \(form) with the related type as its argument: \(form)(\(type))", id: "relatedTypeArgument")
    }

    /// A related term written as a term of this ontology that it does not declare.
    static func undeclaredTerm(_ spelling: String, ontology: String) -> Self {
        Self(message: "'\(spelling)' is not declared in \(ontology)", id: "undeclaredTerm")
    }

    /// Content written as a `content()` function, which the DSL does not use.
    static let writeContentInBody = Self(
        message: "Write the ontology's content in 'var body: some Content', as a SwiftUI view's body; @Ontology does not read a 'content()' function",
        id: "contentInBody"
    )

    /// A generated individual type would have the name of a declared term.
    static func individualTypeCollides(name: String, className: String) -> Self {
        Self(
            message: "'\(name)' is declared in this ontology, so the individual type of '\(className)' cannot use that name",
            id: "individualTypeName"
        )
    }

}

/// A fix-it message.
struct OntologyFixIt: FixItMessage {
    let message: String
    var id = "relatedTypeArgument"
    var fixItID: MessageID { MessageID(domain: "RDFKitMacros", id: id) }
}
