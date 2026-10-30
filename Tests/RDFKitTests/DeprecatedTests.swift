import Testing
import OWL
import RDF
import RDFCore
import RDFFormats
import RDFKit
import XSD

/// An archive vocabulary with a deprecated property. `Deprecated()` writes
/// `owl:deprecated`, so the file imports `OWL`, which declares `owl:Ontology`
/// as `Ontology`: the ontology type conforms to `RDFCore.Ontology`.
@Ontology
struct Archive: RDFCore.Ontology {
    var body: some Content {
        Namespace("https://archive.example.org/#")
        Class("Record") {
            Type(RDF.Class)
        }
        Property("shelfmark") {
            Domain(Archive.Record)
            Range(XSD.string)
            Deprecated()
        }
    }
}

@Suite("Deprecated() in the DSL", .tags(.ontology, .generated))
struct DeprecatedTests {
    /// `Deprecated()` is `owl:deprecated true` (`xsd:boolean`) in the
    /// term's description, written from the Swift `true` of `XSD.boolean`,
    /// and `@available(*, deprecated)` on its Swift declarations.
    @Test func deprecatedTermsStateOWLDeprecatedTrue() throws {
        let output = try TurtleDecoder().decode(try TurtleEncoder().encode(Archive().ontology))
        let expected = try TurtleDecoder().decode("""
            @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
            @prefix owl: <http://www.w3.org/2002/07/owl#> .
            @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
            @prefix archive: <https://archive.example.org/#> .
            archive:Record a rdfs:Class .
            archive:shelfmark rdfs:domain archive:Record ; rdfs:range xsd:string ; owl:deprecated true .
            """)
        #expect(output.isIsomorphic(to: expected), "\(output)")
    }
}
