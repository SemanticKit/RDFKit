import Foundation

/// The RDF vocabulary namespace.
public enum RDF {
    /// The RDF namespace IRI.
    public static let namespace = Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

    /// rdf:type.
    public static var type: TypeProperty { TypeProperty() }

    /// rdf:subject.
    public static var subject: Subject { Subject() }

    /// rdf:predicate.
    public static var predicate: Predicate { Predicate() }

    /// rdf:object.
    public static var object: Object { Object() }

    /// rdf:reifies.
    public static var reifies: Reifies { Reifies() }

    /// rdf:first.
    public static var first: First { First() }

    /// rdf:rest.
    public static var rest: Rest { Rest() }

    /// rdf:nil.
    public static var nilValue: Nil { Nil() }

    /// rdf:value.
    public static var value: Value { Value() }

    /// rdf:langString.
    public static var langString: LangString { LangString() }

    /// rdf:direction.
    public static var direction: Direction { Direction() }

    /// rdf:language.
    public static var language: Language { Language() }

    /// Returns an rdf container membership property IRI.
    public static func containerMembershipProperty(_ index: Int) throws -> IRI {
        guard index > 0 else {
            throw RDFTermError.invalidContainerMembershipIndex
        }
        return IRI("\(namespace.rawValue)_\(index)")
    }
}

public extension RDF {
    /// rdf:type.
    struct TypeProperty: RDFKit.Property, VocabularyTerm, RelationshipProperty {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("type")
        public init() {}
    }

    /// rdf:subject.
    struct Subject: RDFKit.Property, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("subject")
        public init() {}
    }

    /// rdf:predicate.
    struct Predicate: RDFKit.Property, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("predicate")
        public init() {}
    }

    /// rdf:object.
    struct Object: RDFKit.Property, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("object")
        public init() {}
    }

    /// rdf:reifies.
    struct Reifies: RDFKit.Property, VocabularyTerm, RelationshipProperty {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("reifies")
        public init() {}
    }

    /// rdf:first.
    struct First: RDFKit.Property, VocabularyTerm, RelationshipProperty {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("first")
        public init() {}
    }

    /// rdf:rest.
    struct Rest: RDFKit.Property, VocabularyTerm, RelationshipProperty {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("rest")
        public init() {}
    }

    /// rdf:nil.
    struct Nil: RDFKit.Individual, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("nil")
        public init() {}
    }

    /// rdf:value.
    struct Value: RDFKit.Property, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("value")
        public init() {}
    }

    /// rdf:langString.
    struct LangString: RDFKit.Datatype, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("langString")
        public init() {}
    }

    /// rdf:direction.
    struct Direction: RDFKit.Property, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("direction")
        public init() {}
    }

    /// rdf:language.
    struct Language: RDFKit.Property, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("language")
        public init() {}
    }

    /// rdf:Alt.
    struct Alt: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("Alt")
        public init() {}
    }

    /// rdf:Bag.
    struct Bag: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("Bag")
        public init() {}
    }

    /// rdf:CompoundLiteral.
    struct CompoundLiteral: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("CompoundLiteral")
        public init() {}
    }

    /// rdf:HTML.
    struct HTML: RDFKit.Datatype, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("HTML")
        public init() {}
    }

    /// rdf:JSON.
    struct JSON: RDFKit.Datatype, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("JSON")
        public init() {}
    }

    /// rdf:List.
    struct List: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("List")
        public init() {}
    }

    /// rdf:PlainLiteral.
    struct PlainLiteral: RDFKit.Datatype, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("PlainLiteral")
        public init() {}
    }

    /// rdf:Property.
    struct Property: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("Property")
        public init() {}
    }

    /// rdf:Seq.
    struct Seq: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("Seq")
        public init() {}
    }

    /// rdf:Statement.
    struct Statement: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("Statement")
        public init() {}
    }

    /// rdf:XMLLiteral.
    struct XMLLiteral: RDFKit.Datatype, VocabularyTerm {
        public static let namespace = RDF.namespace
        public static let localName = LocalName("XMLLiteral")
        public init() {}
    }
}
