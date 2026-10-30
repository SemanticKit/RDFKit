import Testing

extension Tag {
    /// The XSD datatypes as Swift value types.
    @Tag static var datatype: Self
    /// Types generated from RDF or from the W3C schema documents.
    @Tag static var generated: Self
    /// Values read where a term leaves the runtime (serialization, translation).
    @Tag static var boundary: Self
}
