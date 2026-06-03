import Foundation

/// Resolves ontology terms declared directly in DSL content.
enum ContentTermResolver {
    /// Returns the term IRIs declared by content.
    static func termIRIs<ContentValue: Content>(in content: ContentValue) throws -> Set<IRI> {
        try declarationIRIs(in: content)
    }

    /// Returns the class IRIs declared by content.
    static func classIRIs<ContentValue: Content>(in content: ContentValue) throws -> Set<IRI> {
        try declarationIRIs(in: content, role: .class)
    }

    /// Returns the property IRIs declared by content.
    static func propertyIRIs<ContentValue: Content>(in content: ContentValue) throws -> Set<IRI> {
        try declarationIRIs(in: content, role: .property)
    }

    /// Returns the datatype IRIs declared by content.
    static func datatypeIRIs<ContentValue: Content>(in content: ContentValue) throws -> Set<IRI> {
        try declarationIRIs(in: content, role: .datatype)
    }

    /// Returns the individual IRIs declared by content.
    static func individualIRIs<ContentValue: Content>(in content: ContentValue) throws -> Set<IRI> {
        try declarationIRIs(in: content, role: .individual)
    }

    private static func declarationIRIs<ContentValue: Content>(
        in content: ContentValue,
        role: OntologyDeclarationRole? = nil
    ) throws -> Set<IRI> {
        let environment = ContentNamespaceResolver.environment(in: content)
        return Set(try iris(in: content, environment: environment, role: role))
    }

    private static func iris(in content: any Content, environment: OntologyEnvironment, role: OntologyDeclarationRole?) throws -> [IRI] {
        var collected: [IRI] = []
        if let term = content as? any RDFClass, role == nil || role == .class {
            collected.append(term.iri)
        }
        if let term = content as? any RDFProperty, role == nil || role == .property {
            collected.append(term.iri)
        }
        if let term = content as? any RDFDatatype, role == nil || role == .datatype {
            collected.append(term.iri)
        }
        if let term = content as? any RDFIndividual, role == nil || role == .individual {
            collected.append(term.iri)
        }
        if let term = content as? any Term, role == nil {
            collected.append(term.iri)
        }
        if let vocabulary = content as? any StandardsVocabulary, role == nil {
            collected.append(contentsOf: try standardsIRIs(in: vocabulary.standardsLabel))
        }
        if let declaration = content as? any NamespaceScopedDeclaration, role == nil || declaration.role == role {
            collected.append(declaration.iri(in: environment))
        }
        if let environmentContent = content as? any EnvironmentResolvedContent {
            collected.append(contentsOf: try iris(in: environmentContent.resolve(in: environment), environment: environment, role: role))
        }
        if let group = content as? ContentGroup {
            for element in group.elements {
                collected.append(contentsOf: try iris(in: element, environment: environment, role: role))
            }
        }
        return collected
    }

    private static func standardsIRIs(in vocabulary: String) throws -> [IRI] {
        try StandardsMatrix.bundled().entries(in: vocabulary).map(\.iri)
    }
}
