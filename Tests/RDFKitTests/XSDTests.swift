import IRIKit
import RDFKit
import Testing

@Suite("XSD through @Ontology", .tags(.ontology, .generated))
struct XSDTests {
    @Test("xsd:nonNegativeInteger is a value, and ranges over it hold UInt", .tags(.property))
    func nonNegativeIntegerIsAValue() {
        let cardinality: OWL.cardinality.Range = 3
        let restriction = OWL.RestrictionIndividual(cardinality: [cardinality])

        #expect(restriction.cardinality.reduce(0, +) == 3)
        #expect(Mirror(reflecting: XSD.nonNegativeInteger()).displayStyle == .struct)
    }

    @Test("The datatype's IRI is projected from the XSD namespace", .tags(.boundary))
    func iriIsProjectedFromTheNamespace() {
        #expect(XSD.nonNegativeInteger.metadata.id == IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
    }
}
