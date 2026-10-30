/// The values one individual has for a property whose range is a datatype
/// with a Swift value type: `[XSD.nonNegativeInteger]` for a property that
/// ranges over `xsd:nonNegativeInteger`.
///
/// `RDFTranslatorPlugin` gives each such property's value type this
/// conformance, and states the literals its documents give an individual
/// with ``IndividualStorage/state(_:for:)``, which keeps the values they
/// denote and the literals that denote none, as a decoder does.
public protocol DatatypePropertyValue: PropertyValue {
    /// The Swift value type of the range.
    associatedtype Member: DatatypeValue

    /// The values.
    var value: [Member] { get set }
}
