import IRIKit

/// A document with further information about the declared term.
///
/// `rdfs:seeAlso`
///
/// The value is the address of an external document that readers dereference,
/// so it is held as an IRI.
///
///     SeeAlso("https://www.w3.org/TR/rdf12-interop/")
public struct SeeAlso: Annotation {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#seeAlso",
        name: "seeAlso",
        label: "seeAlso",
        comment: "Further information about the subject resource."
    )

    /// The address of the document.
    public let document: IRI

    public init(_ document: IRI) {
        self.document = document
    }
}
