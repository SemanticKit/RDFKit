import Foundation
import IRIKit
import RDFCore

/// The OWL ontology.
public struct OWL: Ontology {
    public var content: Content {
        Prefix("dc", "http://purl.org/dc/elements/1.1/")
        Prefix("grddl", "http://www.w3.org/2003/g/data-view#")
        Prefix("owl", "http://www.w3.org/2002/07/owl#")
        Prefix("owl", "http://www.w3.org/2002/07/owl#")
        Prefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
        Prefix("rdfs", "http://www.w3.org/2000/01/rdf-schema#")
        Prefix("xml", "http://www.w3.org/XML/1998/namespace")
        Prefix("xsd", "http://www.w3.org/2001/XMLSchema#")

        Namespace("http://www.w3.org/2002/07/owl#")

        Class("AllDifferent") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("AllDifferent")
            Comment(
                "The class of collections of pairwise different individuals."
            )
        }
        Class("AllDisjointClasses") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("AllDisjointClasses")
            Comment("The class of collections of pairwise disjoint classes.")
        }
        Class("AllDisjointProperties") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("AllDisjointProperties")
            Comment("The class of collections of pairwise disjoint properties.")
        }
        Class("Annotation") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("Annotation")
            Comment(
                "The class of annotated annotations for which the RDF serialization consists of an annotated subject, predicate and object."
            )
        }
        Class("AnnotationProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFTerm.Property)
            Label("AnnotationProperty")
            Comment("The class of annotation properties.")
        }
        Class("AsymmetricProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(OWLTerm.ObjectProperty)
            Label("AsymmetricProperty")
            Comment("The class of asymmetric properties.")
        }
        Class("Axiom") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("Axiom")
            Comment(
                "The class of annotated axioms for which the RDF serialization consists of an annotated subject, predicate and object."
            )
        }
        Class("Class") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Class)
            Label("Class")
            Comment("The class of OWL classes.")
        }
        Class("DataRange") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Datatype)
            Label("DataRange")
            Comment(
                "The class of OWL data ranges, which are special kinds of datatypes. Note: The use of the IRI owl:DataRange has been deprecated as of OWL 2. The IRI rdfs:Datatype SHOULD be used instead."
            )
        }
        Class("DatatypeProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFTerm.Property)
            Label("DatatypeProperty")
            Comment("The class of data properties.")
        }
        Class("DeprecatedClass") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Class)
            Label("DeprecatedClass")
            Comment("The class of deprecated classes.")
        }
        Class("DeprecatedProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFTerm.Property)
            Label("DeprecatedProperty")
            Comment("The class of deprecated properties.")
        }
        Class("FunctionalProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFTerm.Property)
            Label("FunctionalProperty")
            Comment("The class of functional properties.")
        }
        Class("InverseFunctionalProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(OWLTerm.ObjectProperty)
            Label("InverseFunctionalProperty")
            Comment("The class of inverse-functional properties.")
        }
        Class("IrreflexiveProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(OWLTerm.ObjectProperty)
            Label("IrreflexiveProperty")
            Comment("The class of irreflexive properties.")
        }
        Class("NamedIndividual") {
            Type(RDFSTerm.Class)
            SubClassOf(OWLTerm.Thing)
            Label("NamedIndividual")
            Comment("The class of named individuals.")
        }
        Class("NegativePropertyAssertion") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("NegativePropertyAssertion")
            Comment("The class of negative property assertions.")
        }
        Class("Nothing") {
            Type(OWLTerm.Class)
            SubClassOf(OWLTerm.Thing)
            Label("Nothing")
            Comment("This is the empty class.")
        }
        Class("ObjectProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFTerm.Property)
            Label("ObjectProperty")
            Comment("The class of object properties.")
        }
        Class("Ontology") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("Ontology")
            Comment("The class of ontologies.")
        }
        Class("OntologyProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFTerm.Property)
            Label("OntologyProperty")
            Comment("The class of ontology properties.")
        }
        Class("ReflexiveProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(OWLTerm.ObjectProperty)
            Label("ReflexiveProperty")
            Comment("The class of reflexive properties.")
        }
        Class("Restriction") {
            Type(RDFSTerm.Class)
            SubClassOf(OWLTerm.Class)
            Label("Restriction")
            Comment("The class of property restrictions.")
        }
        Class("SymmetricProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(OWLTerm.ObjectProperty)
            Label("SymmetricProperty")
            Comment("The class of symmetric properties.")
        }
        Class("TransitiveProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(OWLTerm.ObjectProperty)
            Label("TransitiveProperty")
            Comment("The class of transitive properties.")
        }
        Class("Thing") {
            Type(OWLTerm.Class)
            Label("Thing")
            Comment("The class of OWL individuals.")
        }

        Property("allValuesFrom") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(RDFSTerm.Class)
            Label("allValuesFrom")
            Comment(
                "The property that determines the class that a universal property restriction refers to."
            )
        }
        Property("annotatedProperty") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Resource)
            Label("annotatedProperty")
            Comment(
                "The property that determines the predicate of an annotated axiom or annotated annotation."
            )
        }
        Property("annotatedSource") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Resource)
            Label("annotatedSource")
            Comment(
                "The property that determines the subject of an annotated axiom or annotated annotation."
            )
        }
        Property("annotatedTarget") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Resource)
            Label("annotatedTarget")
            Comment(
                "The property that determines the object of an annotated axiom or annotated annotation."
            )
        }
        Property("assertionProperty") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.NegativePropertyAssertion)
            Range(RDFTerm.Property)
            Label("assertionProperty")
            Comment(
                "The property that determines the predicate of a negative property assertion."
            )
        }
        Property("backwardCompatibleWith") {
            Type(OWLTerm.AnnotationProperty)
            Type(OWLTerm.OntologyProperty)
            Domain(OWLTerm.Ontology)
            Range(OWLTerm.Ontology)
            Label("backwardCompatibleWith")
            Comment(
                "The annotation property that indicates that a given ontology is backward compatible with another ontology."
            )
        }
        Property("bottomDataProperty") {
            Type(OWLTerm.DatatypeProperty)
            Domain(OWLTerm.Thing)
            Range(RDFSTerm.Literal)
            Label("bottomDataProperty")
            Comment(
                "The data property that does not relate any individual to any data value."
            )
        }
        Property("bottomObjectProperty") {
            Type(OWLTerm.ObjectProperty)
            Domain(OWLTerm.Thing)
            Range(OWLTerm.Thing)
            Label("bottomObjectProperty")
            Comment(
                "The object property that does not relate any two individuals."
            )
        }
        Property("cardinality") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            Label("cardinality")
            Comment(
                "The property that determines the cardinality of an exact cardinality restriction."
            )
        }
        Property("complementOf") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Class)
            Range(OWLTerm.Class)
            Label("complementOf")
            Comment(
                "The property that determines that a given class is the complement of another class."
            )
        }
        Property("datatypeComplementOf") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Datatype)
            Range(RDFSTerm.Datatype)
            Label("datatypeComplementOf")
            Comment(
                "The property that determines that a given data range is the complement of another data range with respect to the data domain."
            )
        }
        Property("deprecated") {
            Type(OWLTerm.AnnotationProperty)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Resource)
            Label("deprecated")
            Comment(
                "The annotation property that indicates that a given entity has been deprecated."
            )
        }
        Property("differentFrom") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Thing)
            Range(OWLTerm.Thing)
            Label("differentFrom")
            Comment(
                "The property that determines that two given individuals are different."
            )
        }
        Property("disjointUnionOf") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Class)
            Range(RDFTerm.List)
            Label("disjointUnionOf")
            Comment(
                "The property that determines that a given class is equivalent to the disjoint union of a collection of other classes."
            )
        }
        Property("disjointWith") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Class)
            Range(OWLTerm.Class)
            Label("disjointWith")
            Comment(
                "The property that determines that two given classes are disjoint."
            )
        }
        Property("distinctMembers") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.AllDifferent)
            Range(RDFTerm.List)
            Label("distinctMembers")
            Comment(
                "The property that determines the collection of pairwise different individuals in a owl:AllDifferent axiom."
            )
        }
        Property("equivalentClass") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Class)
            Range(RDFSTerm.Class)
            Label("equivalentClass")
            Comment(
                "The property that determines that two given classes are equivalent, and that is used to specify datatype definitions."
            )
        }
        Property("equivalentProperty") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.Property)
            Range(RDFTerm.Property)
            Label("equivalentProperty")
            Comment(
                "The property that determines that two given properties are equivalent."
            )
        }
        Property("hasKey") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Class)
            Range(RDFTerm.List)
            Label("hasKey")
            Comment(
                "The property that determines the collection of properties that jointly build a key."
            )
        }
        Property("hasSelf") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(RDFSTerm.Resource)
            Label("hasSelf")
            Comment(
                "The property that determines the property that a self restriction refers to."
            )
        }
        Property("hasValue") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(RDFSTerm.Resource)
            Label("hasValue")
            Comment(
                "The property that determines the individual that a has-value restriction refers to."
            )
        }
        Property("imports") {
            Type(OWLTerm.OntologyProperty)
            Domain(OWLTerm.Ontology)
            Range(OWLTerm.Ontology)
            Label("imports")
            Comment(
                "The property that is used for importing other ontologies into a given ontology."
            )
        }
        Property("incompatibleWith") {
            Type(OWLTerm.AnnotationProperty)
            Type(OWLTerm.OntologyProperty)
            Domain(OWLTerm.Ontology)
            Range(OWLTerm.Ontology)
            Label("incompatibleWith")
            Comment(
                "The annotation property that indicates that a given ontology is incompatible with another ontology."
            )
        }
        Property("intersectionOf") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Class)
            Range(RDFTerm.List)
            Label("intersectionOf")
            Comment(
                "The property that determines the collection of classes or data ranges that build an intersection."
            )
        }
        Property("inverseOf") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.ObjectProperty)
            Range(OWLTerm.ObjectProperty)
            Label("inverseOf")
            Comment(
                "The property that determines that two given properties are inverse."
            )
        }
        Property("maxCardinality") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            Label("maxCardinality")
            Comment(
                "The property that determines the cardinality of a maximum cardinality restriction."
            )
        }
        Property("maxQualifiedCardinality") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            Label("maxQualifiedCardinality")
            Comment(
                "The property that determines the cardinality of a maximum qualified cardinality restriction."
            )
        }
        Property("members") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFTerm.List)
            Label("members")
            Comment(
                "The property that determines the collection of members in either a owl:AllDifferent, owl:AllDisjointClasses or owl:AllDisjointProperties axiom."
            )
        }
        Property("minCardinality") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            Label("minCardinality")
            Comment(
                "The property that determines the cardinality of a minimum cardinality restriction."
            )
        }
        Property("minQualifiedCardinality") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            Label("minQualifiedCardinality")
            Comment(
                "The property that determines the cardinality of a minimum qualified cardinality restriction."
            )
        }
        Property("onClass") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(OWLTerm.Class)
            Label("onClass")
            Comment(
                "The property that determines the class that a qualified object cardinality restriction refers to."
            )
        }
        Property("onDataRange") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(RDFSTerm.Datatype)
            Label("onDataRange")
            Comment(
                "The property that determines the data range that a qualified data cardinality restriction refers to."
            )
        }
        Property("onDatatype") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Datatype)
            Range(RDFSTerm.Datatype)
            Label("onDatatype")
            Comment(
                "The property that determines the datatype that a datatype restriction refers to."
            )
        }
        Property("oneOf") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Class)
            Range(RDFTerm.List)
            Label("oneOf")
            Comment(
                "The property that determines the collection of individuals or data values that build an enumeration."
            )
        }
        Property("onProperties") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(RDFTerm.List)
            Label("onProperties")
            Comment(
                "The property that determines the n-tuple of properties that a property restriction on an n-ary data range refers to."
            )
        }
        Property("onProperty") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(RDFTerm.Property)
            Label("onProperty")
            Comment(
                "The property that determines the property that a property restriction refers to."
            )
        }
        Property("priorVersion") {
            Type(OWLTerm.AnnotationProperty)
            Type(OWLTerm.OntologyProperty)
            Domain(OWLTerm.Ontology)
            Range(OWLTerm.Ontology)
            Label("priorVersion")
            Comment(
                "The annotation property that indicates the predecessor ontology of a given ontology."
            )
        }
        Property("propertyChainAxiom") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.ObjectProperty)
            Range(RDFTerm.List)
            Label("propertyChainAxiom")
            Comment(
                "The property that determines the n-tuple of properties that build a sub property chain of a given property."
            )
        }
        Property("propertyDisjointWith") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.Property)
            Range(RDFTerm.Property)
            Label("propertyDisjointWith")
            Comment(
                "The property that determines that two given properties are disjoint."
            )
        }
        Property("qualifiedCardinality") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            Label("qualifiedCardinality")
            Comment(
                "The property that determines the cardinality of an exact qualified cardinality restriction."
            )
        }
        Property("sameAs") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Thing)
            Range(OWLTerm.Thing)
            Label("sameAs")
            Comment(
                "The property that determines that two given individuals are equal."
            )
        }
        Property("someValuesFrom") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Restriction)
            Range(RDFSTerm.Class)
            Label("someValuesFrom")
            Comment(
                "The property that determines the class that an existential property restriction refers to."
            )
        }
        Property("sourceIndividual") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.NegativePropertyAssertion)
            Range(OWLTerm.Thing)
            Label("sourceIndividual")
            Comment(
                "The property that determines the subject of a negative property assertion."
            )
        }
        Property("targetIndividual") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.NegativePropertyAssertion)
            Range(OWLTerm.Thing)
            Label("targetIndividual")
            Comment(
                "The property that determines the object of a negative object property assertion."
            )
        }
        Property("targetValue") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.NegativePropertyAssertion)
            Range(RDFSTerm.Literal)
            Label("targetValue")
            Comment(
                "The property that determines the value of a negative data property assertion."
            )
        }
        Property("topDataProperty") {
            Type(OWLTerm.DatatypeProperty)
            Domain(OWLTerm.Thing)
            Range(RDFSTerm.Literal)
            Label("topDataProperty")
            Comment(
                "The data property that relates every individual to every data value."
            )
        }
        Property("topObjectProperty") {
            Type(OWLTerm.ObjectProperty)
            Domain(OWLTerm.Thing)
            Range(OWLTerm.Thing)
            Label("topObjectProperty")
            Comment("The object property that relates every two individuals.")
        }
        Property("unionOf") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Class)
            Range(RDFTerm.List)
            Label("unionOf")
            Comment(
                "The property that determines the collection of classes or data ranges that build a union."
            )
        }
        Property("versionIRI") {
            Type(OWLTerm.OntologyProperty)
            Domain(OWLTerm.Ontology)
            Range(OWLTerm.Ontology)
            Label("versionIRI")
            Comment(
                "The property that identifies the version IRI of an ontology."
            )
        }
        Property("versionInfo") {
            Type(OWLTerm.AnnotationProperty)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Resource)
            Label("versionInfo")
            Comment(
                "The annotation property that provides version information for an ontology or another OWL construct."
            )
        }
        Property("withRestrictions") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Datatype)
            Range(RDFTerm.List)
            Label("withRestrictions")
            Comment(
                "The property that determines the collection of facet-value pairs that define a datatype restriction."
            )
        }
    }
}
