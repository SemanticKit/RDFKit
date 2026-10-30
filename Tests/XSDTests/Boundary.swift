import RDFCore
import XSD

// Reading the fixture's literals into the XSD value types, at the boundary.

/// The Swift type of the XSD datatype whose IRI is the literal's datatype
/// IRI, as a decoder finds it.
func xsdDatatype(of literal: Literal) -> (any XSD.SimpleType.Type)? {
    XSD.datatypes.first { $0.datatype.stringValue == literal.datatypeIRI.rawValue }
}

/// The value of `literal` in `datatype`.
func value<Datatype: XSD.SimpleType>(_ datatype: Datatype.Type, _ literal: Literal) throws -> Datatype {
    try Datatype(literal)
}

/// The canonical lexical form of the value of `literal` in `datatype`.
func canonicalForm<Datatype: XSD.SimpleType>(_ datatype: Datatype.Type, _ literal: Literal) throws -> String {
    try Datatype(literal).lexicalForm
}

/// Whether two literals of `datatype` denote equal values.
func denoteEqualValues<Datatype: XSD.SimpleType>(_ datatype: Datatype.Type, _ lhs: Literal, _ rhs: Literal) throws -> Bool {
    try Datatype(lhs) == Datatype(rhs)
}

extension RDFCore.Value {
    /// The literal, when the value is one.
    var literalValue: Literal? {
        if case .literal(let literal) = self { return literal }
        return nil
    }
}
