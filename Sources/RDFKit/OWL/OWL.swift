import Foundation

/// The OWL vocabulary namespace.
public enum OWL {
    /// The OWL namespace IRI.
    public static let namespace = Namespace("http://www.w3.org/2002/07/owl#")

    /// owl:allValuesFrom.
    public static let allValuesFrom = StandardTerm(namespace: namespace, localName: "allValuesFrom")
    /// owl:annotatedProperty.
    public static let annotatedProperty = StandardTerm(namespace: namespace, localName: "annotatedProperty")
    /// owl:annotatedSource.
    public static let annotatedSource = StandardTerm(namespace: namespace, localName: "annotatedSource")
    /// owl:annotatedTarget.
    public static let annotatedTarget = StandardTerm(namespace: namespace, localName: "annotatedTarget")
    /// owl:assertionProperty.
    public static let assertionProperty = StandardTerm(namespace: namespace, localName: "assertionProperty")
    /// owl:backwardCompatibleWith.
    public static let backwardCompatibleWith = StandardTerm(namespace: namespace, localName: "backwardCompatibleWith")
    /// owl:bottomDataProperty.
    public static let bottomDataProperty = StandardTerm(namespace: namespace, localName: "bottomDataProperty")
    /// owl:bottomObjectProperty.
    public static let bottomObjectProperty = StandardTerm(namespace: namespace, localName: "bottomObjectProperty")
    /// owl:cardinality.
    public static let cardinality = StandardTerm(namespace: namespace, localName: "cardinality")
    /// owl:complementOf.
    public static let complementOf = StandardTerm(namespace: namespace, localName: "complementOf")
    /// owl:datatypeComplementOf.
    public static let datatypeComplementOf = StandardTerm(namespace: namespace, localName: "datatypeComplementOf")
    /// owl:deprecated.
    public static let deprecated = StandardTerm(namespace: namespace, localName: "deprecated")
    /// owl:differentFrom.
    public static let differentFrom = StandardTerm(namespace: namespace, localName: "differentFrom")
    /// owl:disjointUnionOf.
    public static let disjointUnionOf = StandardTerm(namespace: namespace, localName: "disjointUnionOf")
    /// owl:disjointWith.
    public static let disjointWith = StandardTerm(namespace: namespace, localName: "disjointWith")
    /// owl:distinctMembers.
    public static let distinctMembers = StandardTerm(namespace: namespace, localName: "distinctMembers")
    /// owl:equivalentClass.
    public static let equivalentClass = StandardTerm(namespace: namespace, localName: "equivalentClass")
    /// owl:equivalentProperty.
    public static let equivalentProperty = StandardTerm(namespace: namespace, localName: "equivalentProperty")
    /// owl:hasKey.
    public static let hasKey = StandardTerm(namespace: namespace, localName: "hasKey")
    /// owl:hasSelf.
    public static let hasSelf = StandardTerm(namespace: namespace, localName: "hasSelf")
    /// owl:hasValue.
    public static let hasValue = StandardTerm(namespace: namespace, localName: "hasValue")
    /// owl:imports.
    public static let imports = StandardTerm(namespace: namespace, localName: "imports")
    /// owl:incompatibleWith.
    public static let incompatibleWith = StandardTerm(namespace: namespace, localName: "incompatibleWith")
    /// owl:intersectionOf.
    public static let intersectionOf = StandardTerm(namespace: namespace, localName: "intersectionOf")
    /// owl:inverseOf.
    public static let inverseOf = StandardTerm(namespace: namespace, localName: "inverseOf")
    /// owl:maxCardinality.
    public static let maxCardinality = StandardTerm(namespace: namespace, localName: "maxCardinality")
    /// owl:maxQualifiedCardinality.
    public static let maxQualifiedCardinality = StandardTerm(namespace: namespace, localName: "maxQualifiedCardinality")
    /// owl:members.
    public static let members = StandardTerm(namespace: namespace, localName: "members")
    /// owl:minCardinality.
    public static let minCardinality = StandardTerm(namespace: namespace, localName: "minCardinality")
    /// owl:minQualifiedCardinality.
    public static let minQualifiedCardinality = StandardTerm(namespace: namespace, localName: "minQualifiedCardinality")
    /// owl:onClass.
    public static let onClass = StandardTerm(namespace: namespace, localName: "onClass")
    /// owl:onDataRange.
    public static let onDataRange = StandardTerm(namespace: namespace, localName: "onDataRange")
    /// owl:onDatatype.
    public static let onDatatype = StandardTerm(namespace: namespace, localName: "onDatatype")
    /// owl:oneOf.
    public static let oneOf = StandardTerm(namespace: namespace, localName: "oneOf")
    /// owl:onProperties.
    public static let onProperties = StandardTerm(namespace: namespace, localName: "onProperties")
    /// owl:onProperty.
    public static let onProperty = StandardTerm(namespace: namespace, localName: "onProperty")
    /// owl:priorVersion.
    public static let priorVersion = StandardTerm(namespace: namespace, localName: "priorVersion")
    /// owl:propertyChainAxiom.
    public static let propertyChainAxiom = StandardTerm(namespace: namespace, localName: "propertyChainAxiom")
    /// owl:propertyDisjointWith.
    public static let propertyDisjointWith = StandardTerm(namespace: namespace, localName: "propertyDisjointWith")
    /// owl:qualifiedCardinality.
    public static let qualifiedCardinality = StandardTerm(namespace: namespace, localName: "qualifiedCardinality")
    /// owl:sameAs.
    public static let sameAs = StandardTerm(namespace: namespace, localName: "sameAs")
    /// owl:someValuesFrom.
    public static let someValuesFrom = StandardTerm(namespace: namespace, localName: "someValuesFrom")
    /// owl:sourceIndividual.
    public static let sourceIndividual = StandardTerm(namespace: namespace, localName: "sourceIndividual")
    /// owl:targetIndividual.
    public static let targetIndividual = StandardTerm(namespace: namespace, localName: "targetIndividual")
    /// owl:targetValue.
    public static let targetValue = StandardTerm(namespace: namespace, localName: "targetValue")
    /// owl:topDataProperty.
    public static let topDataProperty = StandardTerm(namespace: namespace, localName: "topDataProperty")
    /// owl:topObjectProperty.
    public static let topObjectProperty = StandardTerm(namespace: namespace, localName: "topObjectProperty")
    /// owl:unionOf.
    public static let unionOf = StandardTerm(namespace: namespace, localName: "unionOf")
    /// owl:versionInfo.
    public static let versionInfo = StandardTerm(namespace: namespace, localName: "versionInfo")
    /// owl:versionIRI.
    public static let versionIRI = StandardTerm(namespace: namespace, localName: "versionIRI")
    /// owl:withRestrictions.
    public static let withRestrictions = StandardTerm(namespace: namespace, localName: "withRestrictions")
}

public extension OWL {
    /// owl:AllDifferent.
    struct AllDifferent: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("AllDifferent"); public init() {} }
    /// owl:AllDisjointClasses.
    struct AllDisjointClasses: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("AllDisjointClasses"); public init() {} }
    /// owl:AllDisjointProperties.
    struct AllDisjointProperties: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("AllDisjointProperties"); public init() {} }
    /// owl:Annotation.
    struct Annotation: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("Annotation"); public init() {} }
    /// owl:AnnotationProperty.
    struct AnnotationProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("AnnotationProperty"); public init() {} }
    /// owl:AsymmetricProperty.
    struct AsymmetricProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("AsymmetricProperty"); public init() {} }
    /// owl:Axiom.
    struct Axiom: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("Axiom"); public init() {} }
    /// owl:Class.
    struct Class: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("Class"); public init() {} }
    /// owl:DataRange.
    struct DataRange: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("DataRange"); public init() {} }
    /// owl:DatatypeProperty.
    struct DatatypeProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("DatatypeProperty"); public init() {} }
    /// owl:DeprecatedClass.
    struct DeprecatedClass: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("DeprecatedClass"); public init() {} }
    /// owl:DeprecatedProperty.
    struct DeprecatedProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("DeprecatedProperty"); public init() {} }
    /// owl:FunctionalProperty.
    struct FunctionalProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("FunctionalProperty"); public init() {} }
    /// owl:InverseFunctionalProperty.
    struct InverseFunctionalProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("InverseFunctionalProperty"); public init() {} }
    /// owl:IrreflexiveProperty.
    struct IrreflexiveProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("IrreflexiveProperty"); public init() {} }
    /// owl:NamedIndividual.
    struct NamedIndividual: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("NamedIndividual"); public init() {} }
    /// owl:NegativePropertyAssertion.
    struct NegativePropertyAssertion: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("NegativePropertyAssertion"); public init() {} }
    /// owl:Nothing.
    struct Nothing: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("Nothing"); public init() {} }
    /// owl:ObjectProperty.
    struct ObjectProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("ObjectProperty"); public init() {} }
    /// owl:Ontology.
    struct Ontology: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("Ontology"); public init() {} }
    /// owl:OntologyProperty.
    struct OntologyProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("OntologyProperty"); public init() {} }
    /// owl:ReflexiveProperty.
    struct ReflexiveProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("ReflexiveProperty"); public init() {} }
    /// owl:Restriction.
    struct Restriction: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("Restriction"); public init() {} }
    /// owl:SymmetricProperty.
    struct SymmetricProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("SymmetricProperty"); public init() {} }
    /// owl:Thing.
    struct Thing: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("Thing"); public init() {} }
    /// owl:TransitiveProperty.
    struct TransitiveProperty: RDFKit.Class, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("TransitiveProperty"); public init() {} }
}
