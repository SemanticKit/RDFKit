import Foundation

public extension OWL {
    /// The OWL standard ontology authored as Swift content.
    static var ontology: some Content {
        OWLOntology().content
    }
}

/// OWL standard ontology content authored with ontology declarations.
private struct OWLOntology: Ontology {
    var content: some Content {
        Namespace("http://www.w3.org/2002/07/owl#")
        Alias("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
        Alias("rdfs", Namespace("http://www.w3.org/2000/01/rdf-schema#"))
        Alias("owl", Namespace("http://www.w3.org/2002/07/owl#"))

        Class("AllDifferent") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("AllDifferent")
            Comment("The class of collections of pairwise different individuals.")
        }
        Class("AllDisjointClasses") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("AllDisjointClasses")
            Comment("The class of collections of pairwise disjoint classes.")
        }
        Class("AllDisjointProperties") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("AllDisjointProperties")
            Comment("The class of collections of pairwise disjoint properties.")
        }
        Class("Annotation") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Annotation")
            Comment("The class of annotated annotations for which the RDF serialization consists of an annotated subject, predicate and object.")
        }
        Class("AnnotationProperty") {
            Type(RDFS.Class.self)
            SubClassOf(RDF.Property.self)
            IsDefinedBy()
            Label("AnnotationProperty")
            Comment("The class of annotation properties.")
        }
        Class("AsymmetricProperty") {
            Type(RDFS.Class.self)
            SubClassOf(OWL.ObjectProperty.self)
            IsDefinedBy()
            Label("AsymmetricProperty")
            Comment("The class of asymmetric properties.")
        }
        Class("Axiom") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Axiom")
            Comment("The class of annotated axioms for which the RDF serialization consists of an annotated subject, predicate and object.")
        }
        Class("Class") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Class.self)
            IsDefinedBy()
            Label("Class")
            Comment("The class of OWL classes.")
        }
        Class("DataRange") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Datatype.self)
            IsDefinedBy()
            Label("DataRange")
            Comment("The class of OWL data ranges, which are special kinds of datatypes. Note: The use of the IRI owl:DataRange has been deprecated as of OWL 2. The IRI rdfs:Datatype SHOULD be used instead.")
        }
        Class("DatatypeProperty") {
            Type(RDFS.Class.self)
            SubClassOf(RDF.Property.self)
            IsDefinedBy()
            Label("DatatypeProperty")
            Comment("The class of data properties.")
        }
        Class("DeprecatedClass") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Class.self)
            IsDefinedBy()
            Label("DeprecatedClass")
            Comment("The class of deprecated classes.")
        }
        Class("DeprecatedProperty") {
            Type(RDFS.Class.self)
            SubClassOf(RDF.Property.self)
            IsDefinedBy()
            Label("DeprecatedProperty")
            Comment("The class of deprecated properties.")
        }
        Class("FunctionalProperty") {
            Type(RDFS.Class.self)
            SubClassOf(RDF.Property.self)
            IsDefinedBy()
            Label("FunctionalProperty")
            Comment("The class of functional properties.")
        }
        Class("InverseFunctionalProperty") {
            Type(RDFS.Class.self)
            SubClassOf(OWL.ObjectProperty.self)
            IsDefinedBy()
            Label("InverseFunctionalProperty")
            Comment("The class of inverse-functional properties.")
        }
        Class("IrreflexiveProperty") {
            Type(RDFS.Class.self)
            SubClassOf(OWL.ObjectProperty.self)
            IsDefinedBy()
            Label("IrreflexiveProperty")
            Comment("The class of irreflexive properties.")
        }
        Class("NamedIndividual") {
            Type(RDFS.Class.self)
            SubClassOf(OWL.Thing.self)
            IsDefinedBy()
            Label("NamedIndividual")
            Comment("The class of named individuals.")
        }
        Class("NegativePropertyAssertion") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("NegativePropertyAssertion")
            Comment("The class of negative property assertions.")
        }
        Class("Nothing") {
            Type(OWL.Class.self)
            SubClassOf(OWL.Thing.self)
            IsDefinedBy()
            Label("Nothing")
            Comment("This is the empty class.")
        }
        Class("ObjectProperty") {
            Type(RDFS.Class.self)
            SubClassOf(RDF.Property.self)
            IsDefinedBy()
            Label("ObjectProperty")
            Comment("The class of object properties.")
        }
        Class("Ontology") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Ontology")
            Comment("The class of ontologies.")
        }
        Class("OntologyProperty") {
            Type(RDFS.Class.self)
            SubClassOf(RDF.Property.self)
            IsDefinedBy()
            Label("OntologyProperty")
            Comment("The class of ontology properties.")
        }
        Class("ReflexiveProperty") {
            Type(RDFS.Class.self)
            SubClassOf(OWL.ObjectProperty.self)
            IsDefinedBy()
            Label("ReflexiveProperty")
            Comment("The class of reflexive properties.")
        }
        Class("Restriction") {
            Type(RDFS.Class.self)
            SubClassOf(OWL.Class.self)
            IsDefinedBy()
            Label("Restriction")
            Comment("The class of property restrictions.")
        }
        Class("SymmetricProperty") {
            Type(RDFS.Class.self)
            SubClassOf(OWL.ObjectProperty.self)
            IsDefinedBy()
            Label("SymmetricProperty")
            Comment("The class of symmetric properties.")
        }
        Class("TransitiveProperty") {
            Type(RDFS.Class.self)
            SubClassOf(OWL.ObjectProperty.self)
            IsDefinedBy()
            Label("TransitiveProperty")
            Comment("The class of transitive properties.")
        }
        Class("Thing") {
            Type(OWL.Class.self)
            IsDefinedBy()
            Label("Thing")
            Comment("The class of OWL individuals.")
        }

        Property("allValuesFrom") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("allValuesFrom")
            Comment("The property that determines the class that a universal property restriction refers to.")
        }
        Property("annotatedProperty") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("annotatedProperty")
            Comment("The property that determines the predicate of an annotated axiom or annotated annotation.")
        }
        Property("annotatedSource") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("annotatedSource")
            Comment("The property that determines the subject of an annotated axiom or annotated annotation.")
        }
        Property("annotatedTarget") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("annotatedTarget")
            Comment("The property that determines the object of an annotated axiom or annotated annotation.")
        }
        Property("assertionProperty") {
            Type(RDF.Property.self)
            Domain(OWL.NegativePropertyAssertion.self)
            Range(RDF.Property.self)
            IsDefinedBy()
            Label("assertionProperty")
            Comment("The property that determines the predicate of a negative property assertion.")
        }
        Property("backwardCompatibleWith") {
            Type(OWL.AnnotationProperty.self)
            Type(OWL.OntologyProperty.self)
            Domain(OWL.Ontology.self)
            Range(OWL.Ontology.self)
            IsDefinedBy()
            Label("backwardCompatibleWith")
            Comment("The annotation property that indicates that a given ontology is backward compatible with another ontology.")
        }
        Property("bottomDataProperty") {
            Type(OWL.DatatypeProperty.self)
            Domain(OWL.Thing.self)
            Range(RDFS.Literal.self)
            IsDefinedBy()
            Label("bottomDataProperty")
            Comment("The data property that does not relate any individual to any data value.")
        }
        Property("bottomObjectProperty") {
            Type(OWL.ObjectProperty.self)
            Domain(OWL.Thing.self)
            Range(OWL.Thing.self)
            IsDefinedBy()
            Label("bottomObjectProperty")
            Comment("The object property that does not relate any two individuals.")
        }
        Property("cardinality") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            IsDefinedBy()
            Label("cardinality")
            Comment("The property that determines the cardinality of an exact cardinality restriction.")
        }
        Property("complementOf") {
            Type(RDF.Property.self)
            Domain(OWL.Class.self)
            Range(OWL.Class.self)
            IsDefinedBy()
            Label("complementOf")
            Comment("The property that determines that a given class is the complement of another class.")
        }
        Property("datatypeComplementOf") {
            Type(RDF.Property.self)
            Domain(RDFS.Datatype.self)
            Range(RDFS.Datatype.self)
            IsDefinedBy()
            Label("datatypeComplementOf")
            Comment("The property that determines that a given data range is the complement of another data range with respect to the data domain.")
        }
        Property("deprecated") {
            Type(OWL.AnnotationProperty.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("deprecated")
            Comment("The annotation property that indicates that a given entity has been deprecated.")
        }
        Property("differentFrom") {
            Type(RDF.Property.self)
            Domain(OWL.Thing.self)
            Range(OWL.Thing.self)
            IsDefinedBy()
            Label("differentFrom")
            Comment("The property that determines that two given individuals are different.")
        }
        Property("disjointUnionOf") {
            Type(RDF.Property.self)
            Domain(OWL.Class.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("disjointUnionOf")
            Comment("The property that determines that a given class is equivalent to the disjoint union of a collection of other classes.")
        }
        Property("disjointWith") {
            Type(RDF.Property.self)
            Domain(OWL.Class.self)
            Range(OWL.Class.self)
            IsDefinedBy()
            Label("disjointWith")
            Comment("The property that determines that two given classes are disjoint.")
        }
        Property("distinctMembers") {
            Type(RDF.Property.self)
            Domain(OWL.AllDifferent.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("distinctMembers")
            Comment("The property that determines the collection of pairwise different individuals in a owl:AllDifferent axiom.")
        }
        Property("equivalentClass") {
            Type(RDF.Property.self)
            Domain(RDFS.Class.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("equivalentClass")
            Comment("The property that determines that two given classes are equivalent, and that is used to specify datatype definitions.")
        }
        Property("equivalentProperty") {
            Type(RDF.Property.self)
            Domain(RDF.Property.self)
            Range(RDF.Property.self)
            IsDefinedBy()
            Label("equivalentProperty")
            Comment("The property that determines that two given properties are equivalent.")
        }
        Property("hasKey") {
            Type(RDF.Property.self)
            Domain(OWL.Class.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("hasKey")
            Comment("The property that determines the collection of properties that jointly build a key.")
        }
        Property("hasSelf") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("hasSelf")
            Comment("The property that determines the property that a self restriction refers to.")
        }
        Property("hasValue") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("hasValue")
            Comment("The property that determines the individual that a has-value restriction refers to.")
        }
        Property("imports") {
            Type(OWL.OntologyProperty.self)
            Domain(OWL.Ontology.self)
            Range(OWL.Ontology.self)
            IsDefinedBy()
            Label("imports")
            Comment("The property that is used for importing other ontologies into a given ontology.")
        }
        Property("incompatibleWith") {
            Type(OWL.AnnotationProperty.self)
            Type(OWL.OntologyProperty.self)
            Domain(OWL.Ontology.self)
            Range(OWL.Ontology.self)
            IsDefinedBy()
            Label("incompatibleWith")
            Comment("The annotation property that indicates that a given ontology is incompatible with another ontology.")
        }
        Property("intersectionOf") {
            Type(RDF.Property.self)
            Domain(RDFS.Class.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("intersectionOf")
            Comment("The property that determines the collection of classes or data ranges that build an intersection.")
        }
        Property("inverseOf") {
            Type(RDF.Property.self)
            Domain(OWL.ObjectProperty.self)
            Range(OWL.ObjectProperty.self)
            IsDefinedBy()
            Label("inverseOf")
            Comment("The property that determines that two given properties are inverse.")
        }
        Property("maxCardinality") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            IsDefinedBy()
            Label("maxCardinality")
            Comment("The property that determines the cardinality of a maximum cardinality restriction.")
        }
        Property("maxQualifiedCardinality") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            IsDefinedBy()
            Label("maxQualifiedCardinality")
            Comment("The property that determines the cardinality of a maximum qualified cardinality restriction.")
        }
        Property("members") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("members")
            Comment("The property that determines the collection of members in either a owl:AllDifferent, owl:AllDisjointClasses or owl:AllDisjointProperties axiom.")
        }
        Property("minCardinality") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            IsDefinedBy()
            Label("minCardinality")
            Comment("The property that determines the cardinality of a minimum cardinality restriction.")
        }
        Property("minQualifiedCardinality") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            IsDefinedBy()
            Label("minQualifiedCardinality")
            Comment("The property that determines the cardinality of a minimum qualified cardinality restriction.")
        }
        Property("onClass") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(OWL.Class.self)
            IsDefinedBy()
            Label("onClass")
            Comment("The property that determines the class that a qualified object cardinality restriction refers to.")
        }
        Property("onDataRange") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(RDFS.Datatype.self)
            IsDefinedBy()
            Label("onDataRange")
            Comment("The property that determines the data range that a qualified data cardinality restriction refers to.")
        }
        Property("onDatatype") {
            Type(RDF.Property.self)
            Domain(RDFS.Datatype.self)
            Range(RDFS.Datatype.self)
            IsDefinedBy()
            Label("onDatatype")
            Comment("The property that determines the datatype that a datatype restriction refers to.")
        }
        Property("oneOf") {
            Type(RDF.Property.self)
            Domain(RDFS.Class.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("oneOf")
            Comment("The property that determines the collection of individuals or data values that build an enumeration.")
        }
        Property("onProperties") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("onProperties")
            Comment("The property that determines the n-tuple of properties that a property restriction on an n-ary data range refers to.")
        }
        Property("onProperty") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(RDF.Property.self)
            IsDefinedBy()
            Label("onProperty")
            Comment("The property that determines the property that a property restriction refers to.")
        }
        Property("priorVersion") {
            Type(OWL.AnnotationProperty.self)
            Type(OWL.OntologyProperty.self)
            Domain(OWL.Ontology.self)
            Range(OWL.Ontology.self)
            IsDefinedBy()
            Label("priorVersion")
            Comment("The annotation property that indicates the predecessor ontology of a given ontology.")
        }
        Property("propertyChainAxiom") {
            Type(RDF.Property.self)
            Domain(OWL.ObjectProperty.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("propertyChainAxiom")
            Comment("The property that determines the n-tuple of properties that build a sub property chain of a given property.")
        }
        Property("propertyDisjointWith") {
            Type(RDF.Property.self)
            Domain(RDF.Property.self)
            Range(RDF.Property.self)
            IsDefinedBy()
            Label("propertyDisjointWith")
            Comment("The property that determines that two given properties are disjoint.")
        }
        Property("qualifiedCardinality") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            IsDefinedBy()
            Label("qualifiedCardinality")
            Comment("The property that determines the cardinality of an exact qualified cardinality restriction.")
        }
        Property("sameAs") {
            Type(RDF.Property.self)
            Domain(OWL.Thing.self)
            Range(OWL.Thing.self)
            IsDefinedBy()
            Label("sameAs")
            Comment("The property that determines that two given individuals are equal.")
        }
        Property("someValuesFrom") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("someValuesFrom")
            Comment("The property that determines the class that an existential property restriction refers to.")
        }
        Property("sourceIndividual") {
            Type(RDF.Property.self)
            Domain(OWL.NegativePropertyAssertion.self)
            Range(OWL.Thing.self)
            IsDefinedBy()
            Label("sourceIndividual")
            Comment("The property that determines the subject of a negative property assertion.")
        }
        Property("targetIndividual") {
            Type(RDF.Property.self)
            Domain(OWL.NegativePropertyAssertion.self)
            Range(OWL.Thing.self)
            IsDefinedBy()
            Label("targetIndividual")
            Comment("The property that determines the object of a negative object property assertion.")
        }
        Property("targetValue") {
            Type(RDF.Property.self)
            Domain(OWL.NegativePropertyAssertion.self)
            Range(RDFS.Literal.self)
            IsDefinedBy()
            Label("targetValue")
            Comment("The property that determines the value of a negative data property assertion.")
        }
        Property("topDataProperty") {
            Type(OWL.DatatypeProperty.self)
            Domain(OWL.Thing.self)
            Range(RDFS.Literal.self)
            IsDefinedBy()
            Label("topDataProperty")
            Comment("The data property that relates every individual to every data value.")
        }
        Property("topObjectProperty") {
            Type(OWL.ObjectProperty.self)
            Domain(OWL.Thing.self)
            Range(OWL.Thing.self)
            IsDefinedBy()
            Label("topObjectProperty")
            Comment("The object property that relates every two individuals.")
        }
        Property("unionOf") {
            Type(RDF.Property.self)
            Domain(RDFS.Class.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("unionOf")
            Comment("The property that determines the collection of classes or data ranges that build a union.")
        }
        Property("versionIRI") {
            Type(OWL.OntologyProperty.self)
            Domain(OWL.Ontology.self)
            Range(OWL.Ontology.self)
            IsDefinedBy()
            Label("versionIRI")
            Comment("The property that identifies the version IRI of an ontology.")
        }
        Property("versionInfo") {
            Type(OWL.AnnotationProperty.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("versionInfo")
            Comment("The annotation property that provides version information for an ontology or another OWL construct.")
        }
        Property("withRestrictions") {
            Type(RDF.Property.self)
            Domain(RDFS.Datatype.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("withRestrictions")
            Comment("The property that determines the collection of facet-value pairs that define a datatype restriction.")
        }
    }
}
