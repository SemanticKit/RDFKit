import Foundation
import Testing
@testable import RDFKit

extension OntologyTests {
    @Test func owlOntologyUsesDeclarationDSL() throws {
        let content = OWL.ontology
        let classes = owlIRIs([
            "AllDifferent",
            "AllDisjointClasses",
            "AllDisjointProperties",
            "Annotation",
            "AnnotationProperty",
            "AsymmetricProperty",
            "Axiom",
            "Class",
            "DataRange",
            "DatatypeProperty",
            "DeprecatedClass",
            "DeprecatedProperty",
            "FunctionalProperty",
            "InverseFunctionalProperty",
            "IrreflexiveProperty",
            "NamedIndividual",
            "NegativePropertyAssertion",
            "Nothing",
            "ObjectProperty",
            "Ontology",
            "OntologyProperty",
            "ReflexiveProperty",
            "Restriction",
            "SymmetricProperty",
            "Thing",
            "TransitiveProperty"
        ])
        let properties = owlIRIs([
            "allValuesFrom",
            "annotatedProperty",
            "annotatedSource",
            "annotatedTarget",
            "assertionProperty",
            "backwardCompatibleWith",
            "bottomDataProperty",
            "bottomObjectProperty",
            "cardinality",
            "complementOf",
            "datatypeComplementOf",
            "deprecated",
            "differentFrom",
            "disjointUnionOf",
            "disjointWith",
            "distinctMembers",
            "equivalentClass",
            "equivalentProperty",
            "hasKey",
            "hasSelf",
            "hasValue",
            "imports",
            "incompatibleWith",
            "intersectionOf",
            "inverseOf",
            "maxCardinality",
            "maxQualifiedCardinality",
            "members",
            "minCardinality",
            "minQualifiedCardinality",
            "onClass",
            "onDataRange",
            "onDatatype",
            "onProperties",
            "onProperty",
            "oneOf",
            "priorVersion",
            "propertyChainAxiom",
            "propertyDisjointWith",
            "qualifiedCardinality",
            "sameAs",
            "someValuesFrom",
            "sourceIndividual",
            "targetIndividual",
            "targetValue",
            "topDataProperty",
            "topObjectProperty",
            "unionOf",
            "versionIRI",
            "versionInfo",
            "withRestrictions"
        ])
        let terms = classes.union(properties)
        let facts = ContentFactResolver.facts(in: content)

        #expect(try ContentTermResolver.classIRIs(in: content) == classes)
        #expect(try ContentTermResolver.propertyIRIs(in: content) == properties)
        #expect(try ContentTermResolver.termIRIs(in: content) == terms)
        #expect(terms.count == 77)
        #expect(classes.count == 26)
        #expect(properties.count == 51)
        #expect(facts.count == 77)
        #expect(facts.values.allSatisfy { $0.isDefinedBy == [OWL().iri] })
        #expect(facts.values.allSatisfy { $0.labels.isEmpty == false })
        #expect(facts[OWL.Thing.iri]?.types == [OWL.Class.iri])
        #expect(facts[OWL.Nothing.iri]?.types == [OWL.Class.iri])
        #expect(facts[OWL.Nothing.iri]?.superclasses == [OWL.Thing.iri])
        #expect(facts[OWL.AnnotationProperty.iri]?.superclasses == [RDF.Property.iri])
        #expect(facts[OWL.AsymmetricProperty.iri]?.superclasses == [OWL.ObjectProperty.iri])
        #expect(facts[OWL.Restriction.iri]?.superclasses == [OWL.Class.iri])
        #expect(facts[OWL.allValuesFrom.iri]?.types == [RDF.Property.iri])
        #expect(facts[OWL.allValuesFrom.iri]?.domains == [OWL.Restriction.iri])
        #expect(facts[OWL.allValuesFrom.iri]?.ranges == [RDFS.Class.iri])
        #expect(facts[OWL.backwardCompatibleWith.iri]?.types == [OWL.AnnotationProperty.iri, OWL.OntologyProperty.iri])
        #expect(facts[OWL.imports.iri]?.types == [OWL.OntologyProperty.iri])
        #expect(facts[OWL.versionInfo.iri]?.types == [OWL.AnnotationProperty.iri])
        #expect(facts[OWL.cardinality.iri]?.ranges == [IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger")])
        #expect(facts[OWL.sameAs.iri]?.domains == [OWL.Thing.iri])
        #expect(facts[OWL.sameAs.iri]?.ranges == [OWL.Thing.iri])
    }

    private func owlIRIs(_ localNames: [String]) -> Set<IRI> {
        Set(localNames.map(owlIRI))
    }

    private func owlIRI(_ localName: String) -> IRI {
        IRI("http://www.w3.org/2002/07/owl#\(localName)")
    }
}
