import Foundation
import IRIKit

/// A prefix alias bound to a namespace.
public struct Prefix: Sendable {
    /// The alias prefix.
    public let prefix: String

    /// The namespace IRI the prefix abbreviates.
    public let namespace: IRI

    /// Creates a prefix alias.
    public init(_ prefix: String, _ namespace: IRI) {
        self.prefix = prefix
        self.namespace = namespace
    }
}



extension Prefix: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "http://semantickit.io/o/2026/06/rdfkit#Prefix",
        name: "Prefix",
        label: "Prefix",
        comment: "The prefix of the Ontology."
    )
}


// MARK: Known Common Prefixes

extension Prefix {
    /// @prefix dc: <http://purl.org/dc/elements/1.1/> .
    public static let dc: Prefix = Prefix(
        "dc",
        "http://purl.org/dc/elements/1.1/"
    )

    /// @prefix grddl: <http://www.w3.org/2003/g/data-view#> .
    public static var grddl: Self {
        get {
            Prefix(
                "grddl",
                "http://www.w3.org/2003/g/data-view#"
            )
        }
    }

    /// @prefix owl: <http://www.w3.org/2002/07/owl#> .
    public static var owl: Self {
        get {
            Prefix(
                "owl",
                "http://www.w3.org/2002/07/owl#"
            )
        }
    }

    /// @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    public static var rdf: Self {
        get {
            Prefix(
                "rdf",
                "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            )
        }
    }

    /// @prefix rdfkit: <http://semantickit.io/o/2026/06/rdfkit#> .
    public static var rdfkit: Self {
        get {
            Prefix(
                "rdfkit",
                "http://semantickit.io/o/2026/06/rdfkit#"
            )
        }
    }

    /// @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    public static let rdfs = Prefix(
        "rdfs",
        "http://www.w3.org/2000/01/rdf-schema#"
    )

    /// @prefix xml: <http://www.w3.org/XML/1998/namespace> .
    public static let xml = Prefix(
        "xml",
        "http://www.w3.org/XML/1998/namespace"
    )

    /// @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
    public static let xsd = Prefix("xsd", "http://www.w3.org/2001/XMLSchema#")
}

