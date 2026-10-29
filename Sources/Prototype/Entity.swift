//
//  Entity.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/21/26.
//

/// An ontology entity declared in the DSL.
///
/// Represents the declared thing itself, not an instance of it.
/// Contains class-level metadata derived from the DSL declarations.
///
/// The Swift type is the entity's identity inside the runtime. Its IRI lives
/// only in ``metadata``, which is read at the boundary.
public protocol Entity: Node {
    /// The class-level metadata.
    static var metadata: any ContentMetadata { get }
}


// MARK: Generated Type Metadata

extension Entity {

}
