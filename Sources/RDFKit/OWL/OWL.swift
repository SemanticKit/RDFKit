import RDFCore

/// The OWL 2 Schema vocabulary (OWL 2), as owl.ttl publishes it.
@Ontology
public struct OWL: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/2002/07/owl#")

        Class("Class") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Class)
            Label("Class")
            Comment("The class of OWL classes.")
        }

        Class("Thing") {
            Type(OWL.Class)
            Label("Thing")
            Comment("The class of OWL individuals.")
        }

        Class("Ontology") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Ontology")
            Comment("The class of ontologies.")
        }

        Class("Restriction") {
            Type(RDFS.Class)
            SubClassOf(OWL.Class)
            Label("Restriction")
            Comment("The class of property restrictions.")
        }

        Class("Axiom") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Axiom")
            Comment("The class of annotated axioms for which the RDF serialization consists of an annotated subject, predicate and object.")
        }

        Class("Annotation") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Annotation")
            Comment("The class of annotated annotations for which the RDF serialization consists of an annotated subject, predicate and object.")
        }

        Class("AllDifferent") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("AllDifferent")
            Comment("The class of collections of pairwise different individuals.")
        }

        Class("AllDisjointClasses") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("AllDisjointClasses")
            Comment("The class of collections of pairwise disjoint classes.")
        }

        Class("AllDisjointProperties") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("AllDisjointProperties")
            Comment("The class of collections of pairwise disjoint properties.")
        }

        Class("NegativePropertyAssertion") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("NegativePropertyAssertion")
            Comment("The class of negative property assertions.")
        }

        Class("DeprecatedClass") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Class)
            Label("DeprecatedClass")
            Comment("The class of deprecated classes.")
        }

        Class("ObjectProperty") {
            Type(RDFS.Class)
            SubClassOf(RDF.Property)
            Label("ObjectProperty")
            Comment("The class of object properties.")
        }

        Class("DatatypeProperty") {
            Type(RDFS.Class)
            SubClassOf(RDF.Property)
            Label("DatatypeProperty")
            Comment("The class of data properties.")
        }

        Class("AnnotationProperty") {
            Type(RDFS.Class)
            SubClassOf(RDF.Property)
            Label("AnnotationProperty")
            Comment("The class of annotation properties.")
        }

        Class("OntologyProperty") {
            Type(RDFS.Class)
            SubClassOf(RDF.Property)
            Label("OntologyProperty")
            Comment("The class of ontology properties.")
        }

        Class("FunctionalProperty") {
            Type(RDFS.Class)
            SubClassOf(RDF.Property)
            Label("FunctionalProperty")
            Comment("The class of functional properties.")
        }

        Class("DeprecatedProperty") {
            Type(RDFS.Class)
            SubClassOf(RDF.Property)
            Label("DeprecatedProperty")
            Comment("The class of deprecated properties.")
        }

        Class("InverseFunctionalProperty") {
            Type(RDFS.Class)
            SubClassOf(OWL.ObjectProperty)
            Label("InverseFunctionalProperty")
            Comment("The class of inverse-functional properties.")
        }

        Class("TransitiveProperty") {
            Type(RDFS.Class)
            SubClassOf(OWL.ObjectProperty)
            Label("TransitiveProperty")
            Comment("The class of transitive properties.")
        }

        Class("SymmetricProperty") {
            Type(RDFS.Class)
            SubClassOf(OWL.ObjectProperty)
            Label("SymmetricProperty")
            Comment("The class of symmetric properties.")
        }

        Class("AsymmetricProperty") {
            Type(RDFS.Class)
            SubClassOf(OWL.ObjectProperty)
            Label("AsymmetricProperty")
            Comment("The class of asymmetric properties.")
        }

        Class("ReflexiveProperty") {
            Type(RDFS.Class)
            SubClassOf(OWL.ObjectProperty)
            Label("ReflexiveProperty")
            Comment("The class of reflexive properties.")
        }

        Class("IrreflexiveProperty") {
            Type(RDFS.Class)
            SubClassOf(OWL.ObjectProperty)
            Label("IrreflexiveProperty")
            Comment("The class of irreflexive properties.")
        }

        Class("Nothing") {
            Type(OWL.Class)
            SubClassOf(OWL.Thing)
            Label("Nothing")
            Comment("This is the empty class.")
        }

        Property("equivalentClass") {
            Type(RDF.Property)
            Domain(RDFS.Class)
            Range(RDFS.Class)
            Label("equivalentClass")
            Comment("The property that determines that two given classes are equivalent, and that is used to specify datatype definitions.")
        }

        Property("disjointWith") {
            Type(RDF.Property)
            Domain(OWL.Class)
            Range(OWL.Class)
            Label("disjointWith")
            Comment("The property that determines that two given classes are disjoint.")
        }

        Property("complementOf") {
            Type(RDF.Property)
            Domain(OWL.Class)
            Range(OWL.Class)
            Label("complementOf")
            Comment("The property that determines that a given class is the complement of another class.")
        }

        Property("unionOf") {
            Type(RDF.Property)
            Domain(RDFS.Class)
            Range(RDF.List)
            Label("unionOf")
            Comment("The property that determines the collection of classes or data ranges that build a union.")
        }

        Property("intersectionOf") {
            Type(RDF.Property)
            Domain(RDFS.Class)
            Range(RDF.List)
            Label("intersectionOf")
            Comment("The property that determines the collection of classes or data ranges that build an intersection.")
        }

        Property("oneOf") {
            Type(RDF.Property)
            Domain(RDFS.Class)
            Range(RDF.List)
            Label("oneOf")
            Comment("The property that determines the collection of individuals or data values that build an enumeration.")
        }

        Property("disjointUnionOf") {
            Type(RDF.Property)
            Domain(OWL.Class)
            Range(RDF.List)
            Label("disjointUnionOf")
            Comment("The property that determines that a given class is equivalent to the disjoint union of a collection of other classes.")
        }

        Property("hasKey") {
            Type(RDF.Property)
            Domain(OWL.Class)
            Range(RDF.List)
            Label("hasKey")
            Comment("The property that determines the collection of properties that jointly build a key.")
        }

        Property("inverseOf") {
            Type(RDF.Property)
            Domain(OWL.ObjectProperty)
            Range(OWL.ObjectProperty)
            Label("inverseOf")
            Comment("The property that determines that two given properties are inverse.")
        }

        Property("equivalentProperty") {
            Type(RDF.Property)
            Domain(RDF.Property)
            Range(RDF.Property)
            Label("equivalentProperty")
            Comment("The property that determines that two given properties are equivalent.")
        }
    }
}
