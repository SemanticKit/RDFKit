//
//  Tags.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/13/26.
//

import Testing

extension Tag {

    static let W3C: [Tag] = [
        .dc,
        .foaf,
        .owl,
        .rdf,
        .rdfs,
        .xml,
    ]

    @Tag static var dsl: Tag
    @Tag static var rdf: Tag
    @Tag static var owl: Tag
    @Tag static var rdfs: Tag
    @Tag static var xml: Tag
    @Tag static var dc: Tag
    @Tag static var foaf: Tag
}
