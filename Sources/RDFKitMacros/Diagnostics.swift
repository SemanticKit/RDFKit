import SwiftDiagnostics

/// A diagnostic the ontology macros report at the authored line it is about.
struct OntologyDiagnostic: DiagnosticMessage {
    let message: String
    let id: String
    let severity: DiagnosticSeverity = .error

    var diagnosticID: MessageID { MessageID(domain: "RDFKitMacros", id: id) }

    /// `Domain<Fauna.Animal>()` or `Domain(Fauna.Animal.self)` written in content.
    static func writeRelatedTypeAsArgument(form: String, type: String) -> Self {
        Self(message: "Write \(form) with the related type as its argument: \(form)(\(type))", id: "relatedTypeArgument")
    }

    /// A related term written as a term of this ontology that it does not declare.
    static func undeclaredTerm(_ spelling: String, ontology: String) -> Self {
        Self(message: "'\(spelling)' is not declared in \(ontology)", id: "undeclaredTerm")
    }

    /// A type the macro generates for a class would have the name of a declared term.
    static func generatedTypeCollides(name: String, className: String) -> Self {
        Self(
            message: "'\(name)' is declared in this ontology, so the type @Ontology generates for '\(className)' cannot use that name",
            id: "generatedTypeName"
        )
    }

    /// A named individual of a class that has no individuals, or that is not
    /// written with its ontology.
    static func individualOfClassWithoutIndividuals(_ spelling: String) -> Self {
        Self(
            message: "'\(spelling)' is not a class with individuals; write a class protocol with its ontology, such as OWL.Thing, and not owl:Nothing or a datatype",
            id: "individualOfClassWithoutIndividuals"
        )
    }

    /// A functional property that would make a value type contain itself.
    static func recursiveValue(property: String, type: String) -> Self {
        Self(
            message: "'\(property)' has at most one '\(type)', which would make the value type '\(type)' contain itself; make the property many-valued",
            id: "recursiveValue"
        )
    }
}

/// A fix-it message.
struct OntologyFixIt: FixItMessage {
    let message: String
    var fixItID: MessageID { MessageID(domain: "RDFKitMacros", id: "relatedTypeArgument") }
}
