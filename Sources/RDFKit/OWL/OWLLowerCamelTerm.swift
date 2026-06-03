import Foundation

/// An OWL term whose RDF local name is lower camel case.
public protocol OWLLowerCamelTerm: OWLTerm {}

public extension OWLLowerCamelTerm {
    /// The OWL local name inferred from the Swift term type using lower camel case.
    static var localName: LocalName {
        let name = String(describing: Self.self)
        return LocalName(name.prefix(1).lowercased() + name.dropFirst())
    }
}
