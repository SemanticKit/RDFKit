//
//  Namespace.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/22/26.
//

import IRIKit

/// The namespace of an ontology. The macro computes each generated type's
/// boundary IRI from it at expansion time.
public struct Namespace: Sendable {
    /// The namespace IRI.
    public let iri: IRI

    public init(_ iri: IRI) {
        self.iri = iri
    }
}


extension Namespace: Entity {
    public static let metadata: any ContentMetadata  = Class.ClassMetadata(
        id: "http://semantickit.io/o/2026/06/rdfkit#Namespace",
        name: "Namespace",
        label: "Namespace",
        comment: "The namespace of the Ontology."
    )
}
