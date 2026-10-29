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

    /// A declared term named like the extension point the ontology generates.
    static func extensionPointCollides(_ name: String, ontology: String) -> Self {
        Self(
            message: "'\(name)' is the extension point @Ontology generates for the properties \(ontology) declares for other ontologies' classes, so no term of \(ontology) can be named '\(name)'",
            id: "extensionPointName"
        )
    }

    /// A property with a domain in this ontology and a domain in another.
    static func mixedDomains(_ property: String, local: String, foreign: String) -> Self {
        Self(
            message: "'\(property)' has the domain '\(local)' of this ontology and the domain '\(foreign)' of another, which would store it twice; declare it for '\(local)' and make '\(local)' a subclass of '\(foreign)'",
            id: "mixedDomains"
        )
    }

    /// A property whose name individuals use for their graph membership.
    static func reservedPropertyName(_ property: String) -> Self {
        Self(
            message: "Individuals keep their place in their graph as 'membership', so a property with a class as its domain cannot be named '\(property)'",
            id: "reservedPropertyName"
        )
    }

    /// A property whose domain has no individuals to give it to.
    static func domainIsNotAClass(property: String, domain: String) -> Self {
        Self(
            message: "'\(domain)' is not a class of individuals, so no individual can have '\(property)'; make its domain a class",
            id: "domainIsNotAClass"
        )
    }

    /// A term declared a second time.
    static func duplicateDeclaration(_ name: String) -> Self {
        Self(message: "'\(name)' is already declared in this ontology", id: "duplicateDeclaration")
    }

    /// Two local names that become the same Swift identifier.
    static func identifierCollides(_ name: String, with other: String, identifier: String) -> Self {
        Self(
            message: "'\(name)' and '\(other)' would both be the Swift type '\(identifier)'; rename one of them",
            id: "identifierCollides"
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
