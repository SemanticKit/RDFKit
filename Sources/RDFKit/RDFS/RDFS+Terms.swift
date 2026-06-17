import RDFCore
import IRIKit

/// Static IRI term references for the RDFS vocabulary.
///
/// These properties provide convenient access to IRI terms defined in the
/// RDFS ontology. The source of truth is the DSL content in `RDFS.content`;
/// these are reference points for cross-ontology annotations.
///
/// Cross-ontology usage:
///     Type(RDFSTerm.Class)
///     Domain(RDFSTerm.Resource)
public enum RDFSTerm {
    /// rdfs:Class
    public static let `Class`: IRI = "http://www.w3.org/2000/01/rdf-schema#Class"
    /// rdfs:Resource
    public static let Resource: IRI = "http://www.w3.org/2000/01/rdf-schema#Resource"
    /// rdfs:Datatype
    public static let Datatype: IRI = "http://www.w3.org/2000/01/rdf-schema#Datatype"
    /// rdfs:Literal
    public static let Literal: IRI = "http://www.w3.org/2000/01/rdf-schema#Literal"
    /// rdfs:Container
    public static let Container: IRI = "http://www.w3.org/2000/01/rdf-schema#Container"
    /// rdfs:ContainerMembershipProperty
    public static let ContainerMembershipProperty: IRI = "http://www.w3.org/2000/01/rdf-schema#ContainerMembershipProperty"
    /// rdfs:seeAlso
    public static let SeeAlso: IRI = "http://www.w3.org/2000/01/rdf-schema#seeAlso"
    /// rdfs:isDefinedBy
    public static let IsDefinedBy: IRI = "http://www.w3.org/2000/01/rdf-schema#isDefinedBy"
    /// rdfs:label
    public static let Label: IRI = "http://www.w3.org/2000/01/rdf-schema#label"
    /// rdfs:comment
    public static let Comment: IRI = "http://www.w3.org/2000/01/rdf-schema#comment"
    /// rdfs:subClassOf
    public static let SubClassOf: IRI = "http://www.w3.org/2000/01/rdf-schema#subClassOf"
    /// rdfs:subPropertyOf
    public static let SubPropertyOf: IRI = "http://www.w3.org/2000/01/rdf-schema#subPropertyOf"
    /// rdfs:domain
    public static let Domain: IRI = "http://www.w3.org/2000/01/rdf-schema#domain"
    /// rdfs:range
    public static let Range: IRI = "http://www.w3.org/2000/01/rdf-schema#range"
    /// rdfs:member
    public static let Member: IRI = "http://www.w3.org/2000/01/rdf-schema#member"
    /// rdfs:Proposition
    public static let Proposition: IRI = "http://www.w3.org/2000/01/rdf-schema#Proposition"
}
