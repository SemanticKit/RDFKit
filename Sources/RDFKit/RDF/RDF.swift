import Foundation

/// The RDF vocabulary namespace.
public enum RDF {
    /// The RDF namespace IRI.
    public static let namespace = Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

    /// rdf:type.
    public static let type = StandardTerm(namespace: namespace, localName: "type")

    /// rdf:subject.
    public static let subject = StandardTerm(namespace: namespace, localName: "subject")

    /// rdf:predicate.
    public static let predicate = StandardTerm(namespace: namespace, localName: "predicate")

    /// rdf:object.
    public static let object = StandardTerm(namespace: namespace, localName: "object")

    /// rdf:reifies.
    public static let reifies = StandardTerm(namespace: namespace, localName: "reifies")

    /// rdf:first.
    public static let first = StandardTerm(namespace: namespace, localName: "first")

    /// rdf:rest.
    public static let rest = StandardTerm(namespace: namespace, localName: "rest")

    /// rdf:nil.
    public static let nilValue = StandardTerm(namespace: namespace, localName: "nil")

    /// rdf:value.
    public static let value = StandardTerm(namespace: namespace, localName: "value")

    /// rdf:langString.
    public static let langString = StandardTerm(namespace: namespace, localName: "langString")

    /// rdf:direction.
    public static let direction = StandardTerm(namespace: namespace, localName: "direction")

    /// rdf:language.
    public static let language = StandardTerm(namespace: namespace, localName: "language")

    /// Returns an rdf container membership property IRI.
    public static func containerMembershipProperty(_ index: Int) throws -> IRI {
        guard index > 0 else {
            throw RDFTermError.invalidContainerMembershipIndex
        }
        return IRI("\(namespace.rawValue)_\(index)")
    }
}

public extension RDF {
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
