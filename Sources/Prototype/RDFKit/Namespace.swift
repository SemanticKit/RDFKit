//
//  Namespace.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/22/26.
//

import IRIKit

public struct Namespace {
    public typealias ID = IRI

    public let id: ID

    /// The target namespace.
    public let namespace: String

    /// Creates a prefix alias.
    public init(_ namespace: String) {
        guard let id = try? ID(validating: namespace) else {
            preconditionFailure(
                "Could not validate the provided namespace identity as an IRI from \(namespace)."
            )
        }

        self.id = id
        self.namespace = namespace
    }
}


extension Namespace: Entity {
    public static let metadata: any ContentMetadata  = Class.ClassMetadata(
        id: "http://semantickit.io/o/2026/06/rdfkit#Namespace",
        name: "Namespace",
        type: "RDFKit.Namespace",
        label: "Namespace",
        comment: "The namespace of the Ontology."
    )
}
