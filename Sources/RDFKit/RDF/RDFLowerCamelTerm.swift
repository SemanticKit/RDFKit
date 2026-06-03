import Foundation

/// An RDF term whose RDF local name is lower camel case.
public protocol RDFLowerCamelTerm: RDFTerm {}

public extension RDFLowerCamelTerm {
    /// The RDF local name inferred from the Swift term type using lower camel case.
    static var localName: LocalName {
        let name = String(describing: Self.self)
        return LocalName(name.prefix(1).lowercased() + name.dropFirst())
    }
}
