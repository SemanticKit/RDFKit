import IRIKit
import RDFCore
import RDFKit
import Testing

@Suite("XSD through @Ontology", .tags(.ontology, .generated))
struct XSDTests {
    @Test("A cardinality is an xsd:nonNegativeInteger literal", .tags(.property))
    func cardinalityIsANonNegativeInteger() throws {
        let graph = IndividualGraph()
        let restriction = OWL.RestrictionIndividual(in: graph, cardinality: ["3"])

        let cardinality = try #require(restriction.cardinality.first)
        #expect(cardinality.lexicalForm == "3")
        #expect(cardinality == XSD.nonNegativeInteger("3"))
        #expect(cardinality != "4")
    }

    @Test("The datatype's IRI is projected from the XSD namespace", .tags(.boundary))
    func iriIsProjectedFromTheNamespace() {
        #expect(XSD.nonNegativeInteger.metadata.id == IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
    }
}
