import Testing
import RDF
import RDFCore
import RDFKit

/// Terms named like Swift keywords: the Swift `@Ontology` writes for them,
/// with the names in backticks wherever Swift requires them, compiles.
@Ontology
struct Keywords: Ontology {
    var body: some Content {
        Namespace("https://keywords.example.org/#")
        Class("Type")
        Class("class") {
            SubClassOf(Keywords.Type)
        }
        Property("in") {
            Domain(Keywords.class)
            Range(Keywords.Type)
        }
        Individual("default") {
            Type(Keywords.class)
        }
    }
}

@Suite("Terms whose names Swift reserves", .tags(.ontology, .generated))
struct SwiftSpellingTests {
    /// `default` is an individual of `class`, which refines `Type`, and has
    /// the property `in`: each is the Swift declaration its name gives.
    @Test func keywordNamedTermsAreTheirDeclarations() {
        let individual = Keywords().default
        #expect(individual === Keywords().default)
        #expect((individual as Any) is any Keywords.`class`)
        #expect((individual as Any) is any Keywords.`Type`)
        #expect(individual.in.isEmpty)
    }
}
