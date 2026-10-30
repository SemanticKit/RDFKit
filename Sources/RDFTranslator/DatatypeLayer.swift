import IRIKit
import RDFCore
import XSD

/// The XML Schema datatypes RDF uses (RDF 1.2 Concepts §5.1), the layer
/// below every module: the `XSD` module, translated from the W3C documents
/// that define them, declares each as a Swift value type and the Swift
/// class that stands for it as a class.
///
/// A property whose range is one of them holds its values as that value
/// type, `[XSD::nonNegativeInteger]`; the translator reads the datatype IRIs
/// of a document's literals here, at the boundary, and checks each
/// literal's lexical form with the datatype's lexical mapping.
struct DatatypeLayer {
    /// The Swift module that declares the datatypes.
    let module: String

    /// The datatypes, by the IRI their declared keys give.
    private let datatypes: [IRI: any XSD::SimpleType.Type]

    init() {
        var datatypes: [IRI: any XSD::SimpleType.Type] = [:]
        for datatype in XSD.datatypes {
            datatypes[try! IRI(validating: datatype.datatype.stringValue)] = datatype  // a namespace and a name
        }
        self.datatypes = datatypes
        module = String(String(reflecting: XSD.datatypes[0]).prefix { $0 != "." })
    }

    /// The Swift type of the datatype `node` denotes, if the layer declares it.
    func datatype(_ node: SubjectTerm) -> (any XSD::SimpleType.Type)? {
        node.iri.flatMap { datatypes[$0] }
    }

    /// Whether `literal` is a literal of the datatype `node` that its Swift
    /// type writes back as it is: its datatype IRI is the datatype's, its
    /// lexical form is in the datatype's lexical space (it is not
    /// ill-typed), and it is the canonical form of its value.
    func holds(_ literal: Literal, as node: SubjectTerm) -> Bool {
        datatype(node)?.init(holding: literal) != nil
    }

    /// The declarations of the layer: a public class for each datatype,
    /// whose Swift class is the one the `XSD` module declares.
    var declarations: Declarations {
        Declarations(module: module, datatypes: XSD.datatypes.map { datatype in
            (SubjectTerm.iri(try! IRI(validating: datatype.datatype.stringValue)), datatype.datatype.name)
        })
    }
}
