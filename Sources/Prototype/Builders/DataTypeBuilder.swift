//
//  DataTypeBuilder.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/22/26.
//

@resultBuilder
public enum DatatypeBuilder {
    public static func buildBlock<each T: Entity>(_ content: repeat each T) -> [AnyEntity] {
        var result: [AnyEntity] = []
        repeat result.append(each content)
        return result
    }
}
