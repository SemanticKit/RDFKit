import Foundation

/// The OWL vocabulary namespace.
public enum OWL {
    /// The OWL namespace IRI.
    public static let namespace = Namespace("http://www.w3.org/2002/07/owl#")

    /// owl:allValuesFrom.
    public static var allValuesFrom: AllValuesFrom { AllValuesFrom() }
    /// owl:annotatedProperty.
    public static var annotatedProperty: AnnotatedProperty { AnnotatedProperty() }
    /// owl:annotatedSource.
    public static var annotatedSource: AnnotatedSource { AnnotatedSource() }
    /// owl:annotatedTarget.
    public static var annotatedTarget: AnnotatedTarget { AnnotatedTarget() }
    /// owl:assertionProperty.
    public static var assertionProperty: AssertionProperty { AssertionProperty() }
    /// owl:backwardCompatibleWith.
    public static var backwardCompatibleWith: BackwardCompatibleWith { BackwardCompatibleWith() }
    /// owl:bottomDataProperty.
    public static var bottomDataProperty: BottomDataProperty { BottomDataProperty() }
    /// owl:bottomObjectProperty.
    public static var bottomObjectProperty: BottomObjectProperty { BottomObjectProperty() }
    /// owl:cardinality.
    public static var cardinality: Cardinality { Cardinality() }
    /// owl:complementOf.
    public static var complementOf: ComplementOf { ComplementOf() }
    /// owl:datatypeComplementOf.
    public static var datatypeComplementOf: DatatypeComplementOf { DatatypeComplementOf() }
    /// owl:deprecated.
    public static var deprecated: Deprecated { Deprecated() }
    /// owl:differentFrom.
    public static var differentFrom: DifferentFrom { DifferentFrom() }
    /// owl:disjointUnionOf.
    public static var disjointUnionOf: DisjointUnionOf { DisjointUnionOf() }
    /// owl:disjointWith.
    public static var disjointWith: DisjointWith { DisjointWith() }
    /// owl:distinctMembers.
    public static var distinctMembers: DistinctMembers { DistinctMembers() }
    /// owl:equivalentClass.
    public static var equivalentClass: EquivalentClass { EquivalentClass() }
    /// owl:equivalentProperty.
    public static var equivalentProperty: EquivalentProperty { EquivalentProperty() }
    /// owl:hasKey.
    public static var hasKey: HasKey { HasKey() }
    /// owl:hasSelf.
    public static var hasSelf: HasSelf { HasSelf() }
    /// owl:hasValue.
    public static var hasValue: HasValue { HasValue() }
    /// owl:imports.
    public static var imports: Imports { Imports() }
    /// owl:incompatibleWith.
    public static var incompatibleWith: IncompatibleWith { IncompatibleWith() }
    /// owl:intersectionOf.
    public static var intersectionOf: IntersectionOf { IntersectionOf() }
    /// owl:inverseOf.
    public static var inverseOf: InverseOf { InverseOf() }
    /// owl:maxCardinality.
    public static var maxCardinality: MaxCardinality { MaxCardinality() }
    /// owl:maxQualifiedCardinality.
    public static var maxQualifiedCardinality: MaxQualifiedCardinality { MaxQualifiedCardinality() }
    /// owl:members.
    public static var members: Members { Members() }
    /// owl:minCardinality.
    public static var minCardinality: MinCardinality { MinCardinality() }
    /// owl:minQualifiedCardinality.
    public static var minQualifiedCardinality: MinQualifiedCardinality { MinQualifiedCardinality() }
    /// owl:onClass.
    public static var onClass: OnClass { OnClass() }
    /// owl:onDataRange.
    public static var onDataRange: OnDataRange { OnDataRange() }
    /// owl:onDatatype.
    public static var onDatatype: OnDatatype { OnDatatype() }
    /// owl:oneOf.
    public static var oneOf: OneOf { OneOf() }
    /// owl:onProperties.
    public static var onProperties: OnProperties { OnProperties() }
    /// owl:onProperty.
    public static var onProperty: OnProperty { OnProperty() }
    /// owl:priorVersion.
    public static var priorVersion: PriorVersion { PriorVersion() }
    /// owl:propertyChainAxiom.
    public static var propertyChainAxiom: PropertyChainAxiom { PropertyChainAxiom() }
    /// owl:propertyDisjointWith.
    public static var propertyDisjointWith: PropertyDisjointWith { PropertyDisjointWith() }
    /// owl:qualifiedCardinality.
    public static var qualifiedCardinality: QualifiedCardinality { QualifiedCardinality() }
    /// owl:sameAs.
    public static var sameAs: SameAs { SameAs() }
    /// owl:someValuesFrom.
    public static var someValuesFrom: SomeValuesFrom { SomeValuesFrom() }
    /// owl:sourceIndividual.
    public static var sourceIndividual: SourceIndividual { SourceIndividual() }
    /// owl:targetIndividual.
    public static var targetIndividual: TargetIndividual { TargetIndividual() }
    /// owl:targetValue.
    public static var targetValue: TargetValue { TargetValue() }
    /// owl:topDataProperty.
    public static var topDataProperty: TopDataProperty { TopDataProperty() }
    /// owl:topObjectProperty.
    public static var topObjectProperty: TopObjectProperty { TopObjectProperty() }
    /// owl:unionOf.
    public static var unionOf: UnionOf { UnionOf() }
    /// owl:versionInfo.
    public static var versionInfo: VersionInfo { VersionInfo() }
    /// owl:versionIRI.
    public static var versionIRI: VersionIRI { VersionIRI() }
    /// owl:withRestrictions.
    public static var withRestrictions: WithRestrictions { WithRestrictions() }
}

public extension OWL {
    /// owl:allValuesFrom.
    struct AllValuesFrom: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("allValuesFrom"); public init() {} }
    /// owl:annotatedProperty.
    struct AnnotatedProperty: RDFKit.Property, VocabularyTerm, RDFKit.AnnotationProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("annotatedProperty"); public init() {} }
    /// owl:annotatedSource.
    struct AnnotatedSource: RDFKit.Property, VocabularyTerm, RDFKit.AnnotationProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("annotatedSource"); public init() {} }
    /// owl:annotatedTarget.
    struct AnnotatedTarget: RDFKit.Property, VocabularyTerm, RDFKit.AnnotationProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("annotatedTarget"); public init() {} }
    /// owl:assertionProperty.
    struct AssertionProperty: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("assertionProperty"); public init() {} }
    /// owl:backwardCompatibleWith.
    struct BackwardCompatibleWith: RDFKit.Property, VocabularyTerm, RDFKit.AnnotationProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("backwardCompatibleWith"); public init() {} }
    /// owl:bottomDataProperty.
    struct BottomDataProperty: RDFKit.Property, VocabularyTerm, RDFKit.DatatypeProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("bottomDataProperty"); public init() {} }
    /// owl:bottomObjectProperty.
    struct BottomObjectProperty: RDFKit.Property, VocabularyTerm, RDFKit.ObjectProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("bottomObjectProperty"); public init() {} }
    /// owl:cardinality.
    struct Cardinality: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("cardinality"); public init() {} }
    /// owl:complementOf.
    struct ComplementOf: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("complementOf"); public init() {} }
    /// owl:datatypeComplementOf.
    struct DatatypeComplementOf: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("datatypeComplementOf"); public init() {} }
    /// owl:deprecated.
    struct Deprecated: RDFKit.Property, VocabularyTerm, RDFKit.AnnotationProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("deprecated"); public init() {} }
    /// owl:differentFrom.
    struct DifferentFrom: RDFKit.Property, VocabularyTerm, RelationshipProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("differentFrom"); public init() {} }
    /// owl:disjointUnionOf.
    struct DisjointUnionOf: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("disjointUnionOf"); public init() {} }
    /// owl:disjointWith.
    struct DisjointWith: RDFKit.Property, VocabularyTerm, RelationshipProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("disjointWith"); public init() {} }
    /// owl:distinctMembers.
    struct DistinctMembers: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("distinctMembers"); public init() {} }
    /// owl:equivalentClass.
    struct EquivalentClass: RDFKit.Property, VocabularyTerm, RelationshipProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("equivalentClass"); public init() {} }
    /// owl:equivalentProperty.
    struct EquivalentProperty: RDFKit.Property, VocabularyTerm, RelationshipProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("equivalentProperty"); public init() {} }
    /// owl:hasKey.
    struct HasKey: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("hasKey"); public init() {} }
    /// owl:hasSelf.
    struct HasSelf: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("hasSelf"); public init() {} }
    /// owl:hasValue.
    struct HasValue: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("hasValue"); public init() {} }
    /// owl:imports.
    struct Imports: RDFKit.Property, VocabularyTerm, RDFKit.OntologyProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("imports"); public init() {} }
    /// owl:incompatibleWith.
    struct IncompatibleWith: RDFKit.Property, VocabularyTerm, RDFKit.AnnotationProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("incompatibleWith"); public init() {} }
    /// owl:intersectionOf.
    struct IntersectionOf: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("intersectionOf"); public init() {} }
    /// owl:inverseOf.
    struct InverseOf: RDFKit.Property, VocabularyTerm, RelationshipProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("inverseOf"); public init() {} }
    /// owl:maxCardinality.
    struct MaxCardinality: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("maxCardinality"); public init() {} }
    /// owl:maxQualifiedCardinality.
    struct MaxQualifiedCardinality: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("maxQualifiedCardinality"); public init() {} }
    /// owl:members.
    struct Members: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("members"); public init() {} }
    /// owl:minCardinality.
    struct MinCardinality: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("minCardinality"); public init() {} }
    /// owl:minQualifiedCardinality.
    struct MinQualifiedCardinality: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("minQualifiedCardinality"); public init() {} }
    /// owl:onClass.
    struct OnClass: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("onClass"); public init() {} }
    /// owl:onDataRange.
    struct OnDataRange: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("onDataRange"); public init() {} }
    /// owl:onDatatype.
    struct OnDatatype: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("onDatatype"); public init() {} }
    /// owl:oneOf.
    struct OneOf: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("oneOf"); public init() {} }
    /// owl:onProperties.
    struct OnProperties: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("onProperties"); public init() {} }
    /// owl:onProperty.
    struct OnProperty: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("onProperty"); public init() {} }
    /// owl:priorVersion.
    struct PriorVersion: RDFKit.Property, VocabularyTerm, RDFKit.AnnotationProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("priorVersion"); public init() {} }
    /// owl:propertyChainAxiom.
    struct PropertyChainAxiom: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("propertyChainAxiom"); public init() {} }
    /// owl:propertyDisjointWith.
    struct PropertyDisjointWith: RDFKit.Property, VocabularyTerm, RelationshipProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("propertyDisjointWith"); public init() {} }
    /// owl:qualifiedCardinality.
    struct QualifiedCardinality: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("qualifiedCardinality"); public init() {} }
    /// owl:sameAs.
    struct SameAs: RDFKit.Property, VocabularyTerm, RelationshipProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("sameAs"); public init() {} }
    /// owl:someValuesFrom.
    struct SomeValuesFrom: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("someValuesFrom"); public init() {} }
    /// owl:sourceIndividual.
    struct SourceIndividual: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("sourceIndividual"); public init() {} }
    /// owl:targetIndividual.
    struct TargetIndividual: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("targetIndividual"); public init() {} }
    /// owl:targetValue.
    struct TargetValue: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("targetValue"); public init() {} }
    /// owl:topDataProperty.
    struct TopDataProperty: RDFKit.Property, VocabularyTerm, RDFKit.DatatypeProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("topDataProperty"); public init() {} }
    /// owl:topObjectProperty.
    struct TopObjectProperty: RDFKit.Property, VocabularyTerm, RDFKit.ObjectProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("topObjectProperty"); public init() {} }
    /// owl:unionOf.
    struct UnionOf: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("unionOf"); public init() {} }
    /// owl:versionInfo.
    struct VersionInfo: RDFKit.Property, VocabularyTerm, RDFKit.AnnotationProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("versionInfo"); public init() {} }
    /// owl:versionIRI.
    struct VersionIRI: RDFKit.Property, VocabularyTerm, RDFKit.OntologyProperty { public static let namespace = OWL.namespace; public static let localName = LocalName("versionIRI"); public init() {} }
    /// owl:withRestrictions.
    struct WithRestrictions: RDFKit.Property, VocabularyTerm { public static let namespace = OWL.namespace; public static let localName = LocalName("withRestrictions"); public init() {} }

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
