import RDFCore

/// Generates module-visible peer declarations from an authored ontology root.
///
/// Attach this macro to an `Ontology` root that declares `content: some Content`.
/// The macro parses declarations written with `Class("Name")`,
/// `Datatype("Name")`, `Individual("Name")`, and `Property("Name")`, then emits
/// ordinary peer declarations whose generic roles conform to the appropriate
/// RDFKit term-role protocols.
@attached(peer, names: arbitrary)
public macro OntologyModule() = #externalMacro(module: "RDFKitMacros", type: "OntologyModuleMacro")

public extension RDF {
    /// The authored RDF ontology value.
    static var ontology: RDF {
        RDF()
    }
}

public extension RDFS {
    /// The authored RDF Schema ontology value.
    static var ontology: RDFS {
        RDFS()
    }
}

public extension OWL {
    /// The authored OWL ontology value.
    static var ontology: OWL {
        OWL()
    }
}
