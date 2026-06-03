import Foundation

/// An RDFS term whose RDF local name is lower camel case.
public protocol RDFSLowerCamelTerm: RDFSTerm {}

public extension RDFSLowerCamelTerm {
    /// The RDFS local name inferred from the Swift term type using lower camel case.
    static var localName: LocalName {
        let name = String(describing: Self.self)
        return LocalName(name.prefix(1).lowercased() + name.dropFirst())
    }
}
