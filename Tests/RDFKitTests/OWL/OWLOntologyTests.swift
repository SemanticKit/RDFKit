import Testing
import RDFCore
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLOntologyTests {
    /// owl:Ontology, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.Ontology)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.Ontology {
        var backwardCompatibleWith: Values<any OWL.Ontology> = []
        var imports: Values<any OWL.Ontology> = []
        var incompatibleWith: Values<any OWL.Ontology> = []
        var priorVersion: Values<any OWL.Ontology> = []
        var versionIRI: Values<any OWL.Ontology> = []
    }
}
