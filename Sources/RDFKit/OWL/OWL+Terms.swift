import RDFCore
import IRIKit

/// Static IRI term references for the OWL vocabulary.
///
/// These properties provide convenient access to IRI terms defined in the
/// OWL ontology. The source of truth is the DSL content in `OWL.content`;
/// these are reference points for cross-ontology annotations.
///
/// Cross-ontology usage:
///     Type(OWLTerm.Class)
///     SubClassOf(OWLTerm.ObjectProperty)
public enum OWLTerm {
    /// owl:Class
    public static let `Class`: IRI = "http://www.w3.org/2002/07/owl#Class"
    /// owl:Thing
    public static let Thing: IRI = "http://www.w3.org/2002/07/owl#Thing"
    /// owl:Nothing
    public static let Nothing: IRI = "http://www.w3.org/2002/07/owl#Nothing"
    /// owl:ObjectProperty
    public static let ObjectProperty: IRI = "http://www.w3.org/2002/07/owl#ObjectProperty"
    /// owl:DatatypeProperty
    public static let DatatypeProperty: IRI = "http://www.w3.org/2002/07/owl#DatatypeProperty"
    /// owl:AnnotationProperty
    public static let AnnotationProperty: IRI = "http://www.w3.org/2002/07/owl#AnnotationProperty"
    /// owl:OntologyProperty
    public static let OntologyProperty: IRI = "http://www.w3.org/2002/07/owl#OntologyProperty"
    /// owl:Restriction
    public static let Restriction: IRI = "http://www.w3.org/2002/07/owl#Restriction"
    /// owl:Ontology
    public static let Ontology: IRI = "http://www.w3.org/2002/07/owl#Ontology"
    /// owl:AllDifferent
    public static let AllDifferent: IRI = "http://www.w3.org/2002/07/owl#AllDifferent"
    /// owl:AllDisjointClasses
    public static let AllDisjointClasses: IRI = "http://www.w3.org/2002/07/owl#AllDisjointClasses"
    /// owl:AllDisjointProperties
    public static let AllDisjointProperties: IRI = "http://www.w3.org/2002/07/owl#AllDisjointProperties"
    /// owl:Annotation
    public static let Annotation: IRI = "http://www.w3.org/2002/07/owl#Annotation"
    /// owl:Axiom
    public static let Axiom: IRI = "http://www.w3.org/2002/07/owl#Axiom"
    /// owl:NegativePropertyAssertion
    public static let NegativePropertyAssertion: IRI = "http://www.w3.org/2002/07/owl#NegativePropertyAssertion"
    /// owl:NamedIndividual
    public static let NamedIndividual: IRI = "http://www.w3.org/2002/07/owl#NamedIndividual"
    /// owl:DeprecatedClass
    public static let DeprecatedClass: IRI = "http://www.w3.org/2002/07/owl#DeprecatedClass"
    /// owl:DeprecatedProperty
    public static let DeprecatedProperty: IRI = "http://www.w3.org/2002/07/owl#DeprecatedProperty"
    /// owl:AsymmetricProperty
    public static let AsymmetricProperty: IRI = "http://www.w3.org/2002/07/owl#AsymmetricProperty"
    /// owl:FunctionalProperty
    public static let FunctionalProperty: IRI = "http://www.w3.org/2002/07/owl#FunctionalProperty"
    /// owl:InverseFunctionalProperty
    public static let InverseFunctionalProperty: IRI = "http://www.w3.org/2002/07/owl#InverseFunctionalProperty"
    /// owl:IrreflexiveProperty
    public static let IrreflexiveProperty: IRI = "http://www.w3.org/2002/07/owl#IrreflexiveProperty"
    /// owl:ReflexiveProperty
    public static let ReflexiveProperty: IRI = "http://www.w3.org/2002/07/owl#ReflexiveProperty"
    /// owl:SymmetricProperty
    public static let SymmetricProperty: IRI = "http://www.w3.org/2002/07/owl#SymmetricProperty"
    /// owl:TransitiveProperty
    public static let TransitiveProperty: IRI = "http://www.w3.org/2002/07/owl#TransitiveProperty"
    /// owl:DataRange
    public static let DataRange: IRI = "http://www.w3.org/2002/07/owl#DataRange"
}
