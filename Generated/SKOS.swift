import IRIKit
import RDFCore
import RDFKit
/// label: Concept
///
/// definition: An idea or notion; a unit of thought.
public protocol Concept: RDFS.Resource, AnyObject {
    /// label: is top concept in scheme
    ///
    /// definition: Relates a concept to the concept scheme that it is a top level concept of.
    var topConceptOf: Values<any SKOS.ConceptScheme> {
        get
        set
    }
    /// label: is in semantic relation with
    ///
    /// definition: Links a concept to a concept related by meaning.
    ///
    /// scopeNote: This property should not be used directly, but as a super-property for all properties denoting a relationship of meaning between concepts.
    var semanticRelation: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has broader
    ///
    /// definition: Relates a concept to a concept that is more general in meaning.
    ///
    /// comment: Broader concepts are typically rendered as parents in a concept hierarchy (tree).
    ///
    /// scopeNote: By convention, skos:broader is only used to assert an immediate (i.e. direct) hierarchical link between two conceptual resources.
    var broader: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has narrower
    ///
    /// definition: Relates a concept to a concept that is more specific in meaning.
    ///
    /// scopeNote: By convention, skos:broader is only used to assert an immediate (i.e. direct) hierarchical link between two conceptual resources.
    ///
    /// comment: Narrower concepts are typically rendered as children in a concept hierarchy (tree).
    var narrower: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has related
    ///
    /// definition: Relates a concept to a concept with which there is an associative semantic relationship.
    ///
    /// comment: skos:related is disjoint with skos:broaderTransitive
    var related: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has broader transitive
    ///
    /// definition: skos:broaderTransitive is a transitive superproperty of skos:broader.
    ///
    /// scopeNote: By convention, skos:broaderTransitive is not used to make assertions. Rather, the properties can be used to draw inferences about the transitive closure of the hierarchical relation, which is useful e.g. when implementing a simple query expansion algorithm in a search application.
    var broaderTransitive: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has narrower transitive
    ///
    /// definition: skos:narrowerTransitive is a transitive superproperty of skos:narrower.
    ///
    /// scopeNote: By convention, skos:narrowerTransitive is not used to make assertions. Rather, the properties can be used to draw inferences about the transitive closure of the hierarchical relation, which is useful e.g. when implementing a simple query expansion algorithm in a search application.
    var narrowerTransitive: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: is in mapping relation with
    ///
    /// definition: Relates two concepts coming, by convention, from different schemes, and that have comparable meanings
    ///
    /// comment: These concept mapping relations mirror semantic relations, and the data model defined below is similar (with the exception of skos:exactMatch) to the data model defined for semantic relations. A distinct vocabulary is provided for concept mapping relations, to provide a convenient way to differentiate links within a concept scheme from links between concept schemes. However, this pattern of usage is not a formal requirement of the SKOS data model, and relies on informal definitions of best practice.
    var mappingRelation: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has broader match
    ///
    /// definition: skos:broadMatch is used to state a hierarchical mapping link between two conceptual resources in different concept schemes.
    var broadMatch: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has narrower match
    ///
    /// definition: skos:narrowMatch is used to state a hierarchical mapping link between two conceptual resources in different concept schemes.
    var narrowMatch: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has related match
    ///
    /// definition: skos:relatedMatch is used to state an associative mapping link between two conceptual resources in different concept schemes.
    var relatedMatch: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has exact match
    ///
    /// definition: skos:exactMatch is used to link two concepts, indicating a high degree of confidence that the concepts can be used interchangeably across a wide range of information retrieval applications. skos:exactMatch is a transitive property, and is a sub-property of skos:closeMatch.
    ///
    /// comment: skos:exactMatch is disjoint with each of the properties skos:broadMatch and skos:relatedMatch.
    var exactMatch: Values<any SKOS.Concept> {
        get
        set
    }
    /// label: has close match
    ///
    /// definition: skos:closeMatch is used to link two concepts that are sufficiently similar that they can be used interchangeably in some information retrieval applications. In order to avoid the possibility of "compound errors" when combining mappings across more than two concept schemes, skos:closeMatch is not declared to be a transitive property.
    var closeMatch: Values<any SKOS.Concept> {
        get
        set
    }
}
/// label: Concept Scheme
///
/// definition: A set of concepts, optionally including statements about semantic relationships between those concepts.
///
/// scopeNote: A concept scheme may be defined to include concepts from different sources.
///
/// example: Thesauri, classification schemes, subject heading lists, taxonomies, 'folksonomies', and other types of controlled vocabulary are all examples of concept schemes. Concept schemes are also embedded in glossaries and terminologies.
public protocol ConceptScheme: RDFS.Resource, AnyObject {
    /// label: has top concept
    ///
    /// definition: Relates, by convention, a concept scheme to a concept which is topmost in the broader/narrower concept hierarchies for that scheme, providing an entry point to these hierarchies.
    var hasTopConcept: Values<any SKOS.Concept> {
        get
        set
    }
}
/// label: Collection
///
/// definition: A meaningful collection of concepts.
///
/// scopeNote: Labelled collections can be used where you would like a set of concepts to be displayed under a 'node label' in the hierarchy.
public protocol Collection: RDFS.Resource, AnyObject {
    /// label: has member
    ///
    /// definition: Relates a collection to one of its members.
    var member: Values<any RDFS.Resource> {
        get
        set
    }
}
/// label: Ordered Collection
///
/// definition: An ordered collection of concepts, where both the grouping and the ordering are meaningful.
///
/// scopeNote: Ordered collections can be used where you would like a set of concepts to be displayed in a specific order, and optionally under a 'node label'.
public protocol OrderedCollection: SKOS.Collection, AnyObject {
    /// label: has member list
    ///
    /// definition: Relates an ordered collection to the RDF list containing its members.
    ///
    /// comment: For any resource, every item in the list given as the value of the skos:memberList property is also a value of the skos:member property.
    var memberList: (any RDF.List)? {
        get
        set
    }
}
/// label: is in scheme
///
/// definition: Relates a resource (for example a concept) to a concept scheme in which it is included.
///
/// scopeNote: A concept may be a member of more than one concept scheme.
public protocol InScheme: RDFS.Resource {
    /// label: is in scheme
    ///
    /// definition: Relates a resource (for example a concept) to a concept scheme in which it is included.
    ///
    /// scopeNote: A concept may be a member of more than one concept scheme.
    var inScheme: Values<any SKOS.ConceptScheme> {
        get
        set
    }
}
/// label: preferred label
///
/// definition: The preferred lexical label for a resource, in a given language.
///
/// comment: A resource has no more than one value of skos:prefLabel per language tag, and no more than one value of skos:prefLabel without language tag.
public protocol PrefLabel: RDFS.Resource {
    /// label: preferred label
    ///
    /// definition: The preferred lexical label for a resource, in a given language.
    ///
    /// comment: A resource has no more than one value of skos:prefLabel per language tag, and no more than one value of skos:prefLabel without language tag.
    var prefLabel: Values<any RDFS.Literal> {
        get
        set
    }
}
/// label: alternative label
///
/// definition: An alternative lexical label for a resource.
///
/// example: Acronyms, abbreviations, spelling variants, and irregular plural/singular forms may be included among the alternative labels for a concept. Mis-spelled terms are normally included as hidden labels (see skos:hiddenLabel).
///
/// comment: The range of skos:altLabel is the class of RDF plain literals.
public protocol AltLabel: RDFS.Resource {
    /// label: alternative label
    ///
    /// definition: An alternative lexical label for a resource.
    ///
    /// example: Acronyms, abbreviations, spelling variants, and irregular plural/singular forms may be included among the alternative labels for a concept. Mis-spelled terms are normally included as hidden labels (see skos:hiddenLabel).
    ///
    /// comment: The range of skos:altLabel is the class of RDF plain literals.
    var altLabel: Values<any RDFS.Literal> {
        get
        set
    }
}
/// label: hidden label
///
/// definition: A lexical label for a resource that should be hidden when generating visual displays of the resource, but should still be accessible to free text search operations.
///
/// comment: The range of skos:hiddenLabel is the class of RDF plain literals.
public protocol HiddenLabel: RDFS.Resource {
    /// label: hidden label
    ///
    /// definition: A lexical label for a resource that should be hidden when generating visual displays of the resource, but should still be accessible to free text search operations.
    ///
    /// comment: The range of skos:hiddenLabel is the class of RDF plain literals.
    var hiddenLabel: Values<any RDFS.Literal> {
        get
        set
    }
}
/// label: notation
///
/// definition: A notation, also known as classification code, is a string of characters such as "T58.5" or "303.4833" used to uniquely identify a concept within the scope of a given concept scheme.
///
/// scopeNote: By convention, skos:notation is used with a typed literal in the object position of the triple.
public protocol Notation: RDFS.Resource {
    /// label: notation
    ///
    /// definition: A notation, also known as classification code, is a string of characters such as "T58.5" or "303.4833" used to uniquely identify a concept within the scope of a given concept scheme.
    ///
    /// scopeNote: By convention, skos:notation is used with a typed literal in the object position of the triple.
    var notation: Values<any RDFS.Resource> {
        get
        set
    }
}
/// label: note
///
/// definition: A general note, for any purpose.
///
/// scopeNote: This property may be used directly, or as a super-property for more specific note types.
public protocol Note: RDFS.Resource {
    /// label: note
    ///
    /// definition: A general note, for any purpose.
    ///
    /// scopeNote: This property may be used directly, or as a super-property for more specific note types.
    var note: Values<any RDFS.Resource> {
        get
        set
    }
}
/// label: change note
///
/// definition: A note about a modification to a concept.
public protocol ChangeNote: RDFS.Resource {
    /// label: change note
    ///
    /// definition: A note about a modification to a concept.
    var changeNote: Values<any RDFS.Resource> {
        get
        set
    }
}
/// label: definition
///
/// definition: A statement or formal explanation of the meaning of a concept.
public protocol Definition: RDFS.Resource {
    /// label: definition
    ///
    /// definition: A statement or formal explanation of the meaning of a concept.
    var definition: Values<any RDFS.Resource> {
        get
        set
    }
}
/// label: editorial note
///
/// definition: A note for an editor, translator or maintainer of the vocabulary.
public protocol EditorialNote: RDFS.Resource {
    /// label: editorial note
    ///
    /// definition: A note for an editor, translator or maintainer of the vocabulary.
    var editorialNote: Values<any RDFS.Resource> {
        get
        set
    }
}
/// label: example
///
/// definition: An example of the use of a concept.
public protocol Example: RDFS.Resource {
    /// label: example
    ///
    /// definition: An example of the use of a concept.
    var example: Values<any RDFS.Resource> {
        get
        set
    }
}
/// label: history note
///
/// definition: A note about the past state/use/meaning of a concept.
public protocol HistoryNote: RDFS.Resource {
    /// label: history note
    ///
    /// definition: A note about the past state/use/meaning of a concept.
    var historyNote: Values<any RDFS.Resource> {
        get
        set
    }
}
/// label: scope note
///
/// definition: A note that helps to clarify the meaning and/or the use of a concept.
public protocol ScopeNote: RDFS.Resource {
    /// label: scope note
    ///
    /// definition: A note that helps to clarify the meaning and/or the use of a concept.
    var scopeNote: Values<any RDFS.Resource> {
        get
        set
    }
}
/// The namespace the documents declare these terms in.
public var namespace: String {
    "http://www.w3.org/2004/02/skos/core#"
}
/// The namespace the documents declare these terms in.
public var skosNamespace: String {
    "http://www.w3.org/2004/02/skos/"
}
/// An individual of OWL.Ontology, as the documents state it.
public final class OntologyIndividual: OWL.Ontology, Encodable {
    /// label: backwardCompatibleWith
    ///
    /// comment: The annotation property that indicates that a given ontology is backward compatible with another ontology.
    public var backwardCompatibleWith: Values<any OWL.Ontology> = []
    /// label: imports
    ///
    /// comment: The property that is used for importing other ontologies into a given ontology.
    public var imports: Values<any OWL.Ontology> = []
    /// label: incompatibleWith
    ///
    /// comment: The annotation property that indicates that a given ontology is incompatible with another ontology.
    public var incompatibleWith: Values<any OWL.Ontology> = []
    /// label: priorVersion
    ///
    /// comment: The annotation property that indicates the predecessor ontology of a given ontology.
    public var priorVersion: Values<any OWL.Ontology> = []
    /// label: versionIRI
    ///
    /// comment: The property that identifies the version IRI of an ontology.
    public var versionIRI: Values<any OWL.Ontology> = []
    public init() {
    }
    private enum CodingKeys: CodingKey {
        case id
        case type
        case backwardCompatibleWith
        case imports
        case incompatibleWith
        case priorVersion
        case versionIRI
        var stringValue: String {
            switch self {
            case .id:
                "@id"
            case .type:
                "@type"
            case .backwardCompatibleWith:
                OWL.namespace + "backwardCompatibleWith"
            case .imports:
                OWL.namespace + "imports"
            case .incompatibleWith:
                OWL.namespace + "incompatibleWith"
            case .priorVersion:
                OWL.namespace + "priorVersion"
            case .versionIRI:
                OWL.namespace + "versionIRI"
            }
        }
        init?(stringValue: String) {
            return nil
        }
        var intValue: Int? {
            nil
        }
        init?(intValue: Int) {
            return nil
        }
    }
    /// Writes the individual: its IRI, its classes and the values of its properties.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if self === core {
            try container.encode(SKOS.skosNamespace + "core", forKey: .id)
        }
        try container.encode([OWL.namespace + "Ontology"], forKey: .type)
        try container.encode(backwardCompatibleWith, forKey: .backwardCompatibleWith)
        try container.encode(imports, forKey: .imports)
        try container.encode(incompatibleWith, forKey: .incompatibleWith)
        try container.encode(priorVersion, forKey: .priorVersion)
        try container.encode(versionIRI, forKey: .versionIRI)
    }
}
/// core: <http://www.w3.org/2004/02/skos/core>
nonisolated(unsafe) public let core: OntologyIndividual = { () -> OntologyIndividual in
    let core = OntologyIndividual()
    return core
}()
/// The statements of the documents SKOS is translated from.
public struct OntologyDescription: Encodable, Sendable {
    private enum CodingKeys: CodingKey {
        case id
        case type
        case title
        case contributor
        case description
        case creator
        case seeAlso
        case label
        case isDefinedBy
        case definition
        case scopeNote
        case example
        case disjointWith
        case subClassOf
        case range
        case domain
        case inverseOf
        case subPropertyOf
        case comment
        case unionOf
        case first
        case rest
        var stringValue: String {
            switch self {
            case .id:
                "@id"
            case .type:
                RDF.namespace + "type"
            case .title:
                "http://purl.org/dc/terms/title"
            case .contributor:
                "http://purl.org/dc/terms/contributor"
            case .description:
                "http://purl.org/dc/terms/description"
            case .creator:
                "http://purl.org/dc/terms/creator"
            case .seeAlso:
                RDFS.namespace + "seeAlso"
            case .label:
                RDFS.namespace + "label"
            case .isDefinedBy:
                RDFS.namespace + "isDefinedBy"
            case .definition:
                SKOS.namespace + "definition"
            case .scopeNote:
                SKOS.namespace + "scopeNote"
            case .example:
                SKOS.namespace + "example"
            case .disjointWith:
                OWL.namespace + "disjointWith"
            case .subClassOf:
                RDFS.namespace + "subClassOf"
            case .range:
                RDFS.namespace + "range"
            case .domain:
                RDFS.namespace + "domain"
            case .inverseOf:
                OWL.namespace + "inverseOf"
            case .subPropertyOf:
                RDFS.namespace + "subPropertyOf"
            case .comment:
                RDFS.namespace + "comment"
            case .unionOf:
                OWL.namespace + "unionOf"
            case .first:
                RDF.namespace + "first"
            case .rest:
                RDF.namespace + "rest"
            }
        }
        init?(stringValue: String) {
            return nil
        }
        var intValue: Int? {
            nil
        }
        init?(intValue: Int) {
            return nil
        }
    }
    public init() {
    }
    /// Writes every statement of the documents.
    public func encode(to encoder: any Encoder) throws {
        var subjects = encoder.unkeyedContainer()
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.skosNamespace + "core", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Ontology", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .title)
                try objects.encode(try Literal("SKOS Vocabulary", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .contributor)
                try objects.encode("Dave Beckett")
                try objects.encode("Nikki Rogers")
                try objects.encode("Participants in W3C's Semantic Web Deployment Working Group.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .description)
                try objects.encode(try Literal("An RDF vocabulary for describing the basic structure and content of concept schemes such as thesauri, classification schemes, subject heading lists, taxonomies, 'folksonomies', other types of controlled vocabulary, and also concept schemes embedded in glossaries and terminologies.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .creator)
                try objects.encode("Alistair Miles")
                try objects.encode("Sean Bechhofer")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .seeAlso)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode("http://www.w3.org/TR/skos-reference/", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "Concept", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("Concept", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("An idea or notion; a unit of thought.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "ConceptScheme", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("Concept Scheme", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("A set of concepts, optionally including statements about semantic relationships between those concepts.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("A concept scheme may be defined to include concepts from different sources.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .example)
                try objects.encode(try Literal("Thesauri, classification schemes, subject heading lists, taxonomies, 'folksonomies', and other types of controlled vocabulary are all examples of concept schemes. Concept schemes are also embedded in glossaries and terminologies.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .disjointWith)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "Concept", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "Collection", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("Collection", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("A meaningful collection of concepts.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("Labelled collections can be used where you would like a set of concepts to be displayed under a 'node label' in the hierarchy.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .disjointWith)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "Concept", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "ConceptScheme", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "OrderedCollection", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("Ordered Collection", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("An ordered collection of concepts, where both the grouping and the ordering are meaningful.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("Ordered collections can be used where you would like a set of concepts to be displayed in a specific order, and optionally under a 'node label'.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "Collection", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "inScheme", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("is in scheme", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Relates a resource (for example a concept) to a concept scheme in which it is included.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("A concept may be a member of more than one concept scheme.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "ConceptScheme", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "hasTopConcept", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has top concept", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Relates, by convention, a concept scheme to a concept which is topmost in the broader/narrower concept hierarchies for that scheme, providing an entry point to these hierarchies.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "ConceptScheme", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "Concept", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "topConceptOf", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "topConceptOf", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("is top concept in scheme", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Relates a concept to the concept scheme that it is a top level concept of.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "inScheme", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "hasTopConcept", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "Concept", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "ConceptScheme", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "prefLabel", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("preferred label", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("The preferred lexical label for a resource, in a given language.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "label", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode(try Literal("A resource has no more than one value of skos:prefLabel per language tag, and no more than one value of skos:prefLabel without language tag.", languageTag: "en"))
                try objects.encode(try Literal("The range of skos:prefLabel is the class of RDF plain literals.", languageTag: "en"))
                try objects.encode(try Literal("skos:prefLabel, skos:altLabel and skos:hiddenLabel are pairwise\n      disjoint properties.", languageTag: "en"))
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "altLabel", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("alternative label", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("An alternative lexical label for a resource.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .example)
                try objects.encode(try Literal("Acronyms, abbreviations, spelling variants, and irregular plural/singular forms may be included among the alternative labels for a concept. Mis-spelled terms are normally included as hidden labels (see skos:hiddenLabel).", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "label", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode(try Literal("The range of skos:altLabel is the class of RDF plain literals.", languageTag: "en"))
                try objects.encode(try Literal("skos:prefLabel, skos:altLabel and skos:hiddenLabel are pairwise disjoint properties.", languageTag: "en"))
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "hiddenLabel", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("hidden label", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("A lexical label for a resource that should be hidden when generating visual displays of the resource, but should still be accessible to free text search operations.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "label", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode(try Literal("The range of skos:hiddenLabel is the class of RDF plain literals.", languageTag: "en"))
                try objects.encode(try Literal("skos:prefLabel, skos:altLabel and skos:hiddenLabel are pairwise disjoint properties.", languageTag: "en"))
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "notation", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("notation", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal(#"A notation, also known as classification code, is a string of characters such as "T58.5" or "303.4833" used to uniquely identify a concept within the scope of a given concept scheme."#, languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("By convention, skos:notation is used with a typed literal in the object position of the triple.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "note", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("note", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("A general note, for any purpose.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("This property may be used directly, or as a super-property for more specific note types.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "changeNote", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("change note", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("A note about a modification to a concept.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "note", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "definition", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("definition", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("A statement or formal explanation of the meaning of a concept.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "note", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "editorialNote", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("editorial note", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("A note for an editor, translator or maintainer of the vocabulary.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "note", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "example", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("example", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("An example of the use of a concept.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "note", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "historyNote", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("history note", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("A note about the past state/use/meaning of a concept.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "note", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "scopeNote", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("scope note", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("A note that helps to clarify the meaning and/or the use of a concept.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "note", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "semanticRelation", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("is in semantic relation with", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Links a concept to a concept related by meaning.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("This property should not be used directly, but as a super-property for all properties denoting a relationship of meaning between concepts.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "Concept", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "Concept", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "broader", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has broader", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Relates a concept to a concept that is more general in meaning.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode(try Literal("Broader concepts are typically rendered as parents in a concept hierarchy (tree).", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("By convention, skos:broader is only used to assert an immediate (i.e. direct) hierarchical link between two conceptual resources.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "broaderTransitive", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "narrower", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "narrower", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has narrower", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Relates a concept to a concept that is more specific in meaning.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("By convention, skos:broader is only used to assert an immediate (i.e. direct) hierarchical link between two conceptual resources.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode(try Literal("Narrower concepts are typically rendered as children in a concept hierarchy (tree).", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "narrowerTransitive", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "broader", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "related", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has related", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Relates a concept to a concept with which there is an associative semantic relationship.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "SymmetricProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "semanticRelation", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode(try Literal("skos:related is disjoint with skos:broaderTransitive", languageTag: "en"))
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "broaderTransitive", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has broader transitive", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode("skos:broaderTransitive is a transitive superproperty of skos:broader.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("By convention, skos:broaderTransitive is not used to make assertions. Rather, the properties can be used to draw inferences about the transitive closure of the hierarchical relation, which is useful e.g. when implementing a simple query expansion algorithm in a search application.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "TransitiveProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "semanticRelation", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "narrowerTransitive", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "narrowerTransitive", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has narrower transitive", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode("skos:narrowerTransitive is a transitive superproperty of skos:narrower.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .scopeNote)
                try objects.encode(try Literal("By convention, skos:narrowerTransitive is not used to make assertions. Rather, the properties can be used to draw inferences about the transitive closure of the hierarchical relation, which is useful e.g. when implementing a simple query expansion algorithm in a search application.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "TransitiveProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "semanticRelation", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "broaderTransitive", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "member", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has member", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Relates a collection to one of its members.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "Collection", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    do {
                        var objects = node.nestedUnkeyedContainer(forKey: .type)
                        do {
                            var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                            try node.encode(OWL.namespace + "Class", forKey: .id)
                        }
                    }
                    do {
                        var objects = node.nestedUnkeyedContainer(forKey: .unionOf)
                        do {
                            var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                            do {
                                var objects = node.nestedUnkeyedContainer(forKey: .first)
                                do {
                                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                                    try node.encode(SKOS.namespace + "Concept", forKey: .id)
                                }
                            }
                            do {
                                var objects = node.nestedUnkeyedContainer(forKey: .rest)
                                do {
                                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                                    do {
                                        var objects = node.nestedUnkeyedContainer(forKey: .first)
                                        do {
                                            var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                                            try node.encode(SKOS.namespace + "Collection", forKey: .id)
                                        }
                                    }
                                    do {
                                        var objects = node.nestedUnkeyedContainer(forKey: .rest)
                                        do {
                                            var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                                            try node.encode(RDF.namespace + "nil", forKey: .id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "memberList", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has member list", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Relates an ordered collection to the RDF list containing its members.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "FunctionalProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "OrderedCollection", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "List", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode(try Literal("For any resource, every item in the list given as the value of the\n      skos:memberList property is also a value of the skos:member property.", languageTag: "en"))
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "mappingRelation", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("is in mapping relation with", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("Relates two concepts coming, by convention, from different schemes, and that have comparable meanings", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode(try Literal("These concept mapping relations mirror semantic relations, and the data model defined below is similar (with the exception of skos:exactMatch) to the data model defined for semantic relations. A distinct vocabulary is provided for concept mapping relations, to provide a convenient way to differentiate links within a concept scheme from links between concept schemes. However, this pattern of usage is not a formal requirement of the SKOS data model, and relies on informal definitions of best practice.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "semanticRelation", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "broadMatch", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has broader match", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("skos:broadMatch is used to state a hierarchical mapping link between two conceptual resources in different concept schemes.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "mappingRelation", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "broader", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "narrowMatch", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "narrowMatch", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has narrower match", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("skos:narrowMatch is used to state a hierarchical mapping link between two conceptual resources in different concept schemes.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "mappingRelation", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "narrower", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "broadMatch", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "relatedMatch", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has related match", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("skos:relatedMatch is used to state an associative mapping link between two conceptual resources in different concept schemes.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "SymmetricProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "mappingRelation", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "related", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "exactMatch", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has exact match", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal("skos:exactMatch is used to link two concepts, indicating a high degree of confidence that the concepts can be used interchangeably across a wide range of information retrieval applications. skos:exactMatch is a transitive property, and is a sub-property of skos:closeMatch.", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "SymmetricProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "TransitiveProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "closeMatch", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode(try Literal("skos:exactMatch is disjoint with each of the properties skos:broadMatch and skos:relatedMatch.", languageTag: "en"))
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(SKOS.namespace + "closeMatch", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode(try Literal("has close match", languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.skosNamespace + "core", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .definition)
                try objects.encode(try Literal(#"skos:closeMatch is used to link two concepts that are sufficiently similar that they can be used interchangeably in some information retrieval applications. In order to avoid the possibility of "compound errors" when combining mappings across more than two concept schemes, skos:closeMatch is not declared to be a transitive property."#, languageTag: "en"))
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "SymmetricProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(SKOS.namespace + "mappingRelation", forKey: .id)
                }
            }
        }
    }
}
/// SKOS as its documents state it, every statement of them.
public let ontology = OntologyDescription()
