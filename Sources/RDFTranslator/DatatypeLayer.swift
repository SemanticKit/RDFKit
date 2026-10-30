import IRIKit
import RDFCore
import XSDDefinitions

/// The XML Schema datatypes RDF uses (RDF 1.2 Concepts §5.1), the layer
/// below every module: the `XSD` module declares each as a Swift value type
/// and the Swift class that stands for it as a class.
///
/// The translator learns the datatypes from the same W3C documents, and the
/// same translation of them, that `XSDTranslator` makes the `XSD` module
/// from (``XSDDefinitions/DatatypeDefinitions``): the module's name and the
/// documents come from `RDFTranslatorPlugin`, which finds the target that
/// holds them among the target's dependencies. A datatype is a declaration
/// of that module, as the classes of every module below are, and a property
/// whose range is one holds its values as its value type,
/// `[XSD::nonNegativeInteger]`.
struct DatatypeLayer {
    /// The declarations of the layer: a public class for each datatype,
    /// whose Swift class is the one the `XSD` module declares.
    let declarations: Declarations

    /// The datatypes the documents at `paths` define, which `module`
    /// declares.
    init(module: String, documents paths: [String]) throws {
        let definitions = try DatatypeDefinitions(documents: paths)
        declarations = Declarations(module: module, datatypes: try definitions.datatypes.map { definition in
            // A datatype's IRI is the xsd namespace followed by its name
            // (RDF 1.2 Concepts §5.1), read here, at the boundary.
            (SubjectTerm.iri(try IRI(validating: definitions.namespace + definition.name)), definition.name)
        })
    }

    /// No datatypes: a target that does not depend on the `XSD` module.
    init() {
        declarations = Declarations(module: "", datatypes: [])
    }

    /// Whether `node` is one of the datatypes.
    func isDatatype(_ node: SubjectTerm) -> Bool {
        declarations.classes[node] != nil
    }
}
