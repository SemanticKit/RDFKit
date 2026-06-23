//
//  AnnotationProperty.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/22/26.
//


public protocol AnnotationProperty: Entity {}

public typealias Annotation = AnnotationProperty

public typealias AnyAnnotation = any Annotation

public typealias AnnotationContent = [AnyAnnotation]
