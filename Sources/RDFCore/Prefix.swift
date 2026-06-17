import Foundation

/// A prefix alias bound to a namespace.
public struct Prefix: Node {
    /// The alias prefix.
    public let prefix: String

    /// The target namespace.
    public let namespace: String

    /// Creates a prefix alias.
    public init(_ prefix: String, _ namespace: String) {
        self.prefix = prefix
        self.namespace = namespace
    }
}

public extension Prefix {
    /// @prefix dc: <http://purl.org/dc/elements/1.1/> .
    static var dc: Prefix {
        Prefix(
            "dc",
            "http://purl.org/dc/elements/1.1/"
        )
    }

    /// @prefix grddl: <http://www.w3.org/2003/g/data-view#> .
    static let grddl = Prefix("grddl", "http://www.w3.org/2003/g/data-view#")

    /// @prefix owl: <http://www.w3.org/2002/07/owl#> .
    static let owl = Prefix("owl", "http://www.w3.org/2002/07/owl#")

    /// @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    static let rdf = Prefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")

    /// @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    static let rdfs = Prefix("rdfs", "http://www.w3.org/2000/01/rdf-schema#")

    /// @prefix xml: <http://www.w3.org/XML/1998/namespace> .
    static let xml = Prefix("xml", "http://www.w3.org/XML/1998/namespace")

    /// @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
    static let xsd = Prefix("xsd", "http://www.w3.org/2001/XMLSchema#")
}
