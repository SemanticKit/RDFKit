import IRIKit
import RDFCore
/// The terms of the OWL vocabulary.
public enum OWL {
}
extension OWL {
    /// label: AllDifferent
    ///
    /// comment: The class of collections of pairwise different individuals.
    public protocol AllDifferent: RDFS.Resource, AnyObject {
        /// label: distinctMembers
        ///
        /// comment: The property that determines the collection of pairwise different individuals in a owl:AllDifferent axiom.
        var distinctMembers: Values<any RDF.List> {
            get
            set
        }
    }
    /// label: AllDisjointClasses
    ///
    /// comment: The class of collections of pairwise disjoint classes.
    public protocol AllDisjointClasses: RDFS.Resource, AnyObject {
    }
    /// label: AllDisjointProperties
    ///
    /// comment: The class of collections of pairwise disjoint properties.
    public protocol AllDisjointProperties: RDFS.Resource, AnyObject {
    }
    /// label: Annotation
    ///
    /// comment: The class of annotated annotations for which the RDF serialization consists of an annotated subject, predicate and object.
    public protocol Annotation: RDFS.Resource, AnyObject {
    }
    /// label: AnnotationProperty
    ///
    /// comment: The class of annotation properties.
    public protocol AnnotationProperty: RDF.Property, AnyObject {
    }
    /// label: AsymmetricProperty
    ///
    /// comment: The class of asymmetric properties.
    public protocol AsymmetricProperty: OWL.ObjectProperty, AnyObject {
    }
    /// label: Axiom
    ///
    /// comment: The class of annotated axioms for which the RDF serialization consists of an annotated subject, predicate and object.
    public protocol Axiom: RDFS.Resource, AnyObject {
    }
    /// label: Class
    ///
    /// comment: The class of OWL classes.
    public protocol Class: RDFS.Class, AnyObject {
    }
    /// label: DataRange
    ///
    /// comment: The class of OWL data ranges, which are special kinds of datatypes. Note: The use of the IRI owl:DataRange has been deprecated as of OWL 2. The IRI rdfs:Datatype SHOULD be used instead.
    public protocol DataRange: RDFS.Datatype, AnyObject {
    }
    /// label: DatatypeProperty
    ///
    /// comment: The class of data properties.
    public protocol DatatypeProperty: RDF.Property, AnyObject {
    }
    /// label: DeprecatedClass
    ///
    /// comment: The class of deprecated classes.
    public protocol DeprecatedClass: RDFS.Class, AnyObject {
    }
    /// label: DeprecatedProperty
    ///
    /// comment: The class of deprecated properties.
    public protocol DeprecatedProperty: RDF.Property, AnyObject {
    }
    /// label: FunctionalProperty
    ///
    /// comment: The class of functional properties.
    public protocol FunctionalProperty: RDF.Property, AnyObject {
    }
    /// label: InverseFunctionalProperty
    ///
    /// comment: The class of inverse-functional properties.
    public protocol InverseFunctionalProperty: OWL.ObjectProperty, AnyObject {
    }
    /// label: IrreflexiveProperty
    ///
    /// comment: The class of irreflexive properties.
    public protocol IrreflexiveProperty: OWL.ObjectProperty, AnyObject {
    }
    /// label: NamedIndividual
    ///
    /// comment: The class of named individuals.
    public protocol NamedIndividual: OWL.Thing, AnyObject {
    }
    /// label: NegativePropertyAssertion
    ///
    /// comment: The class of negative property assertions.
    public protocol NegativePropertyAssertion: RDFS.Resource, AnyObject {
        /// label: assertionProperty
        ///
        /// comment: The property that determines the predicate of a negative property assertion.
        var assertionProperty: Values<any RDF.Property> {
            get
            set
        }
        /// label: sourceIndividual
        ///
        /// comment: The property that determines the subject of a negative property assertion.
        var sourceIndividual: Values<any OWL.Thing> {
            get
            set
        }
        /// label: targetIndividual
        ///
        /// comment: The property that determines the object of a negative object property assertion.
        var targetIndividual: Values<any OWL.Thing> {
            get
            set
        }
        /// label: targetValue
        ///
        /// comment: The property that determines the value of a negative data property assertion.
        var targetValue: Values<any RDFS.Literal> {
            get
            set
        }
    }
    /// label: Nothing
    ///
    /// comment: This is the empty class.
    public typealias Nothing = Never
    /// label: ObjectProperty
    ///
    /// comment: The class of object properties.
    public protocol ObjectProperty: RDF.Property, AnyObject {
    }
    /// label: Ontology
    ///
    /// comment: The class of ontologies.
    public protocol Ontology: RDFS.Resource, AnyObject {
        /// label: backwardCompatibleWith
        ///
        /// comment: The annotation property that indicates that a given ontology is backward compatible with another ontology.
        var backwardCompatibleWith: Values<any OWL.Ontology> {
            get
            set
        }
        /// label: imports
        ///
        /// comment: The property that is used for importing other ontologies into a given ontology.
        var imports: Values<any OWL.Ontology> {
            get
            set
        }
        /// label: incompatibleWith
        ///
        /// comment: The annotation property that indicates that a given ontology is incompatible with another ontology.
        var incompatibleWith: Values<any OWL.Ontology> {
            get
            set
        }
        /// label: priorVersion
        ///
        /// comment: The annotation property that indicates the predecessor ontology of a given ontology.
        var priorVersion: Values<any OWL.Ontology> {
            get
            set
        }
        /// label: versionIRI
        ///
        /// comment: The property that identifies the version IRI of an ontology.
        var versionIRI: Values<any OWL.Ontology> {
            get
            set
        }
    }
    /// label: OntologyProperty
    ///
    /// comment: The class of ontology properties.
    public protocol OntologyProperty: RDF.Property, AnyObject {
    }
    /// label: ReflexiveProperty
    ///
    /// comment: The class of reflexive properties.
    public protocol ReflexiveProperty: OWL.ObjectProperty, AnyObject {
    }
    /// label: Restriction
    ///
    /// comment: The class of property restrictions.
    public protocol Restriction: OWL.Class, AnyObject {
    }
    /// label: SymmetricProperty
    ///
    /// comment: The class of symmetric properties.
    public protocol SymmetricProperty: OWL.ObjectProperty, AnyObject {
    }
    /// label: TransitiveProperty
    ///
    /// comment: The class of transitive properties.
    public protocol TransitiveProperty: OWL.ObjectProperty, AnyObject {
    }
    /// label: Thing
    ///
    /// comment: The class of OWL individuals.
    public typealias Thing = RDFS.Resource
    /// label: annotatedProperty
    ///
    /// comment: The property that determines the predicate of an annotated axiom or annotated annotation.
    public protocol AnnotatedProperty: RDFS.Resource {
        /// label: annotatedProperty
        ///
        /// comment: The property that determines the predicate of an annotated axiom or annotated annotation.
        var annotatedProperty: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// label: annotatedSource
    ///
    /// comment: The property that determines the subject of an annotated axiom or annotated annotation.
    public protocol AnnotatedSource: RDFS.Resource {
        /// label: annotatedSource
        ///
        /// comment: The property that determines the subject of an annotated axiom or annotated annotation.
        var annotatedSource: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// label: annotatedTarget
    ///
    /// comment: The property that determines the object of an annotated axiom or annotated annotation.
    public protocol AnnotatedTarget: RDFS.Resource {
        /// label: annotatedTarget
        ///
        /// comment: The property that determines the object of an annotated axiom or annotated annotation.
        var annotatedTarget: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// label: bottomDataProperty
    ///
    /// comment: The data property that does not relate any individual to any data value.
    public protocol BottomDataProperty: RDFS.Resource {
        /// label: bottomDataProperty
        ///
        /// comment: The data property that does not relate any individual to any data value.
        var bottomDataProperty: Values<any RDFS.Literal> {
            get
            set
        }
    }
    /// label: bottomObjectProperty
    ///
    /// comment: The object property that does not relate any two individuals.
    public protocol BottomObjectProperty: RDFS.Resource {
        /// label: bottomObjectProperty
        ///
        /// comment: The object property that does not relate any two individuals.
        var bottomObjectProperty: Values<any OWL.Thing> {
            get
            set
        }
    }
    /// label: deprecated
    ///
    /// comment: The annotation property that indicates that a given entity has been deprecated.
    public protocol Deprecated: RDFS.Resource {
        /// label: deprecated
        ///
        /// comment: The annotation property that indicates that a given entity has been deprecated.
        var deprecated: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// label: differentFrom
    ///
    /// comment: The property that determines that two given individuals are different.
    public protocol DifferentFrom: RDFS.Resource {
        /// label: differentFrom
        ///
        /// comment: The property that determines that two given individuals are different.
        var differentFrom: Values<any OWL.Thing> {
            get
            set
        }
    }
    /// label: members
    ///
    /// comment: The property that determines the collection of members in either a owl:AllDifferent, owl:AllDisjointClasses or owl:AllDisjointProperties axiom.
    public protocol Members: RDFS.Resource {
        /// label: members
        ///
        /// comment: The property that determines the collection of members in either a owl:AllDifferent, owl:AllDisjointClasses or owl:AllDisjointProperties axiom.
        var members: Values<any RDF.List> {
            get
            set
        }
    }
    /// label: sameAs
    ///
    /// comment: The property that determines that two given individuals are equal.
    public protocol SameAs: RDFS.Resource {
        /// label: sameAs
        ///
        /// comment: The property that determines that two given individuals are equal.
        var sameAs: Values<any OWL.Thing> {
            get
            set
        }
    }
    /// label: topDataProperty
    ///
    /// comment: The data property that relates every individual to every data value.
    public protocol TopDataProperty: RDFS.Resource {
        /// label: topDataProperty
        ///
        /// comment: The data property that relates every individual to every data value.
        var topDataProperty: Values<any RDFS.Literal> {
            get
            set
        }
    }
    /// label: topObjectProperty
    ///
    /// comment: The object property that relates every two individuals.
    public protocol TopObjectProperty: RDFS.Resource {
        /// label: topObjectProperty
        ///
        /// comment: The object property that relates every two individuals.
        var topObjectProperty: Values<any OWL.Thing> {
            get
            set
        }
    }
    /// label: versionInfo
    ///
    /// comment: The annotation property that provides version information for an ontology or another OWL construct.
    public protocol VersionInfo: RDFS.Resource {
        /// label: versionInfo
        ///
        /// comment: The annotation property that provides version information for an ontology or another OWL construct.
        var versionInfo: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// The namespace the documents declare these terms in.
    public static var namespace: String {
        "http://www.w3.org/2002/07/owl#"
    }
    /// The namespace the documents declare these terms in.
    public static var namespace07Namespace: String {
        "http://www.w3.org/2002/07/"
    }
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
        if self === owl {
            try container.encode(OWL.namespace07Namespace + "owl", forKey: .id)
        }
        try container.encode([OWL.namespace + "Ontology"], forKey: .type)
        try container.encode(backwardCompatibleWith, forKey: .backwardCompatibleWith)
        try container.encode(imports, forKey: .imports)
        try container.encode(incompatibleWith, forKey: .incompatibleWith)
        try container.encode(priorVersion, forKey: .priorVersion)
        try container.encode(versionIRI, forKey: .versionIRI)
    }
}
/// owl: <http://www.w3.org/2002/07/owl>
///   comment: This ontology partially describes the built-in classes and properties that together form the basis of the RDF/XML syntax of OWL 2. The content of this ontology is based on Tables 6.1 and 6.2 in Section 6.4 of the OWL 2 RDF-Based Semantics specification, available at http://www.w3.org/TR/owl2-rdf-based-semantics/. Please note that those tables do not include the different annotations (labels, comments and rdfs:isDefinedBy links) used in this file. Also note that the descriptions provided in this ontology do not provide a complete and correct formal description of either the syntax or the semantics of the introduced terms (please see the OWL 2 recommendations for the complete and normative specifications). Furthermore, the information provided by this ontology may be misleading if not used with care. This ontology SHOULD NOT be imported into OWL ontologies. Importing this file into an OWL 2 DL ontology will cause it to become an OWL 2 Full ontology and may have other, unexpected, consequences. 
///   versionInfo: $Date: 2009/11/15 10:54:12 $
nonisolated(unsafe) public let owl: OntologyIndividual = { () -> OntologyIndividual in
    let owl = OntologyIndividual()
    owl.versionIRI = [owl]
    return owl
}()
