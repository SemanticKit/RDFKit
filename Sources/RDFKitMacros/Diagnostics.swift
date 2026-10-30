import SwiftDiagnostics

/// A diagnostic the ontology macros report at the authored line it is about.
struct OntologyDiagnostic: DiagnosticMessage {
    let message: String
    let id: String
    let severity: DiagnosticSeverity = .error

    var diagnosticID: MessageID { MessageID(domain: "RDFKitMacros", id: id) }

    /// A term annotation written in content with a generic argument or a
    /// `.self` argument instead of the related type.
    static func writeRelatedTypeAsArgument(form: String, type: String) -> Self {
        Self(message: "Write \(form) with the related type as its argument: \(form)(\(type))", id: "relatedTypeArgument")
    }

    /// A related term written as a term of this ontology that it does not declare.
    static func undeclaredTerm(_ spelling: String, ontology: String) -> Self {
        Self(message: "'\(spelling)' is not declared in \(ontology)", id: "undeclaredTerm")
    }

    /// A generated individual type would have the name of a declared term.
    static func individualTypeCollides(name: String, className: String) -> Self {
        Self(
            message: "'\(name)' is declared in this ontology, so the individual type of '\(className)' cannot use that name",
            id: "individualTypeName"
        )
    }

    /// A named individual of a class that refines another ontology's class.
    static func individualOfForeignClass(_ spelling: String) -> Self {
        Self(
            message: "@Ontology generates the properties of individuals whose classes and superclasses are declared in this ontology (or are RDFS.Resource); '\(spelling)' is not",
            id: "individualOfForeignClass"
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
