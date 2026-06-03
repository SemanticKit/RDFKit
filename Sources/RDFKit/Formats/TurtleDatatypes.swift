import Foundation

/// XML Schema datatype IRIs used while decoding Turtle literals.
enum TurtleDatatypes {
    private static let namespace = "http://www.w3.org/2001/XMLSchema#"

    /// The XML Schema integer datatype IRI.
    static let xsdInteger = IRI("\(namespace)integer")

    /// The XML Schema decimal datatype IRI.
    static let xsdDecimal = IRI("\(namespace)decimal")

    /// The XML Schema double datatype IRI.
    static let xsdDouble = IRI("\(namespace)double")

    /// The XML Schema boolean datatype IRI.
    static let xsdBoolean = IRI("\(namespace)boolean")
}
