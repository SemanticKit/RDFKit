import Foundation
import IRIKit

/// A prefix alias bound to a namespace.
public struct Prefix: Entity {
    public typealias ID = IRI
    public typealias Metadata = any ContentMetadata

    public static let metadata = RDFMetadata(
        id: "http://semantickit.io/o/2026/06/rdfkit#Prefix",
        name: "Prefix",
        type: "RDFKit.Prefix",
        label: "Prefix",
        comment: "The prefix of the Ontology."
    )

    public let id: IRIKit.IRI

    /// The alias prefix.
    public let prefix: String

    /// The target namespace.
    public let namespace: String

    init(_ prefix: String, _ namespace: Namespace) {
        guard let id = try? IRI(validating: "\(Self.metadata.id)\(prefix)") else {
            preconditionFailure(
                "Could not validate the provided namespace identity as an IRI from \(namespace)."
            )
        }
        self.id = id
        self.prefix = prefix
        self.namespace = namespace.namespace
    }

    /// Creates a prefix alias.
    public init(_ prefix: String, _ namespace: String) {
        guard let id = try? IRI(validating: namespace) else {
            preconditionFailure(
                "Could not validate the provided namespace identity as an IRI from \(namespace)."
            )
        }

        self.id = id
        self.prefix = prefix
        self.namespace = namespace
    }
}

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
