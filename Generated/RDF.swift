import IRIKit
import RDFCore
/// The terms of the RDF vocabulary.
public enum RDF {
}
extension RDF {
    /// label: HTML
    ///
    /// comment: The datatype of RDF literals storing fragments of HTML content
    public protocol HTML: RDFS.Literal {
    }
    /// label: langString
    ///
    /// comment: The datatype of language-tagged string values
    public protocol langString: RDFS.Literal {
    }
    /// label: dirLangString
    ///
    /// comment: The datatype of directional language-tagged string values, which includes a language tag and a base direction (either 'ltr' or 'rtl')
    public protocol dirLangString: RDFS.Literal {
    }
    /// deprecated: true
    ///
    /// label: PlainLiteral
    ///
    /// comment: The class of plain (i.e., untyped) literal values, as used in RIF and OWL 2.  Will not be removed until no longer needed there.
    public protocol PlainLiteral: RDFS.Literal {
    }
    /// label: Property
    ///
    /// comment: The class of RDF properties.
    public protocol Property: RDFS.Resource, AnyObject {
    }
    /// label: Statement
    ///
    /// comment: The class of RDF statements.
    public protocol Statement: RDFS.Resource, AnyObject {
        /// label: subject
        ///
        /// comment: The subject of the subject RDF statement.
        var subject: Values<any RDFS.Resource> {
            get
            set
        }
        /// label: predicate
        ///
        /// comment: The predicate of the subject RDF statement.
        var predicate: Values<any RDFS.Resource> {
            get
            set
        }
        /// label: object
        ///
        /// comment: The object of the subject RDF statement.
        var object: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// label: Bag
    ///
    /// comment: The class of unordered containers.
    public protocol Bag: RDFS.Container, AnyObject {
    }
    /// label: Seq
    ///
    /// comment: The class of ordered containers.
    public protocol Seq: RDFS.Container, AnyObject {
    }
    /// label: Alt
    ///
    /// comment: The class of containers of alternatives.
    public protocol Alt: RDFS.Container, AnyObject {
    }
    /// label: List
    ///
    /// comment: The class of RDF Lists.
    public protocol List: RDFS.Resource, AnyObject {
        /// label: first
        ///
        /// comment: The first item in the subject RDF list.
        var first: Values<any RDFS.Resource> {
            get
            set
        }
        /// label: rest
        ///
        /// comment: The rest of the subject RDF list after the first item.
        var rest: Values<any RDF.List> {
            get
            set
        }
    }
    /// label: XMLLiteral
    ///
    /// comment: The datatype of XML literal values.
    public protocol XMLLiteral: RDFS.Literal {
    }
    /// label: JSON
    ///
    /// comment: The datatype of RDF literals storing JSON content.
    public protocol JSON: RDFS.Literal {
    }
    /// label: CompoundLiteral
    ///
    /// comment: A class representing a compound literal.
    public protocol CompoundLiteral: RDFS.Resource, AnyObject {
        /// label: language
        ///
        /// comment: The language component of a CompoundLiteral.
        var language: Values<any RDFS.Resource> {
            get
            set
        }
        /// label: direction
        ///
        /// comment: The base direction component of a CompoundLiteral.
        var direction: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// label: PropositionForm
    ///
    /// comment: The class of abstract, atomic proposition forms. Reserved for basic encoding of propositions.
    public protocol PropositionForm: RDFS.Resource, AnyObject {
        /// label: propositionFormSubject
        ///
        /// comment: The subject component of a proposition form. Reserved for basic encoding of propositions.
        var propositionFormSubject: Values<any RDFS.Resource> {
            get
            set
        }
        /// label: propositionFormPredicate
        ///
        /// comment: The predicate component of a proposition form. Reserved for basic encoding of propositions.
        var propositionFormPredicate: Values<any RDF.Property> {
            get
            set
        }
        /// label: propositionFormObject
        ///
        /// comment: The object component of a proposition form. Reserved for basic encoding of propositions.
        var propositionFormObject: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// label: reifies
    ///
    /// comment: The abstract proposition of a more concrete circumstance.
    public protocol Reifies: RDFS.Resource {
        /// label: reifies
        ///
        /// comment: The abstract proposition of a more concrete circumstance.
        var reifies: Values<any RDFS.Proposition> {
            get
            set
        }
    }
    /// label: value
    ///
    /// comment: Idiomatic property used for structured values.
    public protocol Value: RDFS.Resource {
        /// label: value
        ///
        /// comment: Idiomatic property used for structured values.
        var value: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// The namespace the documents declare these terms in.
    public static var namespace: String {
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    }
}
/// An individual of RDF.List, as the documents state it.
public final class ListIndividual: RDF.List, Encodable {
    /// label: first
    ///
    /// comment: The first item in the subject RDF list.
    public var first: Values<any RDFS.Resource> = []
    /// label: rest
    ///
    /// comment: The rest of the subject RDF list after the first item.
    public var rest: Values<any RDF.List> = []
    public init() {
    }
    private enum CodingKeys: CodingKey {
        case id
        case type
        case first
        case rest
        var stringValue: String {
            switch self {
            case .id:
                "@id"
            case .type:
                "@type"
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
    /// Writes the individual: its IRI, its classes and the values of its properties.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if self === `nil` {
            try container.encode(RDF.namespace + "nil", forKey: .id)
        }
        try container.encode([RDF.namespace + "List"], forKey: .type)
        try container.encode(first, forKey: .first)
        try container.encode(rest, forKey: .rest)
    }
}
/// `nil`: <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>
///   label: nil
///   comment: The empty list, with no items in it. If the rest of a list is nil then the list has no more items in it.
nonisolated(unsafe) public let `nil`: ListIndividual = { () -> ListIndividual in
    let `nil` = ListIndividual()
    return `nil`
}()
