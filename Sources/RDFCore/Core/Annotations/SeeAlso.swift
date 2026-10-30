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
    /// The address of the document.
    public let document: IRI

    public init(_ document: IRI) {
        self.document = document
    }
}
