import SwiftParser
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import RDFKitMacros

@Suite("@OntologyContent body rewrite", .tags(.ontology))
struct OntologyContentMacroTests {
    @Test("Annotations that relate terms are left out, keeping the authored lines")
    func leavesOutTermAnnotations() {
        assertExpansion(
            """
            @OntologyContent
            var body: some Content {
                Namespace("https://zoo.example.org/#")
                Class("Animal") {
                    Type(RDF.Class)
                    Label("Animal")
                    Endangered(Zoo.Animal)
                }
                Class("Keeper") {
                    SubClassOf(Animal)
                    Label(keeperLabel)
                }
                if includeVets {
                    Property("treats") {
                        Domain(Zoo.Vet)
                        Range(Zoo.Animal)
                    }
                }
            }
            """,
            expandedSource: """
            var body: some Content {
                RDFCore.Namespace("https://zoo.example.org/#")
                RDFCore.Class("Animal") {

                        RDFCore.Label("Animal")

                    }
                RDFCore.Class("Keeper") {

                        RDFCore.Label(keeperLabel)
                    }
                if includeVets {
                        RDFCore.Property("treats") {


                        }
                    }
            }
            """
        )
    }

    @Test("Generic and .self spellings are reported with a fix-it")
    func diagnosesOtherSpellings() {
        // The rejected spellings are assembled from parts, so that no source
        // file in the package contains them.
        let generic = "SubClassOf" + "<Zoo.Animal>()"
        let selfArgument = "Domain(Zoo.Animal" + ".self)"
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal") {
                        \(generic)
                        \(selfArgument)
                    }
                }
            }
            """,
            expandedSource: """
            struct Zoo: Ontology {
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    RDFCore.Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Animal") {


                            }
                    #sourceLocation()
                }

                protocol Animal: RDF.Resource {
                }

                /// A member of ``Zoo/Animal`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol AnimalStoring: Zoo.Animal, RDF.ResourceStoring {
                }

                final class AnimalIndividual: Zoo.AnimalStoring, RDFCore.ResourceClass {
                    static let iri: IRIKit.IRI? = "https://zoo.example.org/#Animal"

                    static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.AnimalIndividual.self]

                    /// A member of the class as a property value.
                    typealias Member = any Zoo.Animal

                    let iri: IRIKit.IRI?

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class, denoted by `iri`, or a blank node when it is `nil`.
                    init(iri: IRIKit.IRI? = nil) {
                        self.iri = iri
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        _ = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    }
                }

                /// The descriptions of the terms this ontology declares.
                ///
                /// Encoding them gives the ontology's graph:
                ///
                ///     let document = try TurtleEncoder().encode(Zoo().ontology)
                var ontology: [any RDFCore.Description] {
                    [
                        RDFCore.ClassDescription(Zoo.AnimalIndividual.self),
                    ]
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Write SubClassOf with the related type as its argument: SubClassOf(Zoo.Animal)",
                    line: 6, column: 13,
                    fixIts: [FixItSpec(message: "Write SubClassOf(Zoo.Animal)")]
                ),
                DiagnosticSpec(
                    message: "Write Domain with the related type as its argument: Domain(Zoo.Animal)",
                    line: 7, column: 13,
                    fixIts: [FixItSpec(message: "Write Domain(Zoo.Animal)")]
                ),
            ],
            applyFixIts: ["Write SubClassOf(Zoo.Animal)", "Write Domain(Zoo.Animal)"],
            fixedSource: """
            @Ontology
            struct Zoo: Ontology {
                var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal") {
                        SubClassOf(Zoo.Animal)
                        Domain(Zoo.Animal)
                    }
                }
            }
            """
        )
    }

    @Test("Each statement keeps the line it was authored on")
    func keepsAuthoredLines() throws {
        let source: SourceFileSyntax = """
            struct Zoo {
                @OntologyContent(file: "/Zoo/Zoo.swift", line: 3)
                var body: some Content {
                    Namespace("https://zoo.example.org/#")

                    Class("Animal") {
                        Type(RDF.Class)
                        Label(missingLabel)
                    }
                }
            }
            """
        let variable = try #require(source.statements.first?.item.as(StructDeclSyntax.self)?
            .memberBlock.members.first?.decl.as(VariableDeclSyntax.self))
        let attribute = try #require(variable.attributes.first?.as(AttributeSyntax.self))
        let accessorBlock = try #require(variable.bindings.first?.accessorBlock)
        guard case .getter(let statements) = accessorBlock.accessors else {
            Issue.record("var body has no getter")
            return
        }
        // The getter the compiler gives a body macro on a computed property,
        // built as SwiftSyntaxMacroExpansion builds it: outside the source file.
        let getter = AccessorDeclSyntax(
            accessorSpecifier: .keyword(.get, presence: .missing),
            body: CodeBlockSyntax(leftBrace: accessorBlock.leftBrace, statements: statements, rightBrace: accessorBlock.rightBrace)
        )
        let context = BasicMacroExpansionContext(
            sourceFiles: [source: .init(moduleName: "Zoo", fullFilePath: "/Zoo/Zoo.swift")]
        )

        let body = try OntologyContentMacro.expansion(of: attribute, providingBodyFor: getter, in: context)

        #expect(body.map(\.trimmedDescription) == [
            #"#sourceLocation(file: "/Zoo/Zoo.swift", line: 4)"#,
            #"RDFCore.Namespace("https://zoo.example.org/#")"#,
            #"#sourceLocation(file: "/Zoo/Zoo.swift", line: 6)"#,
            """
            RDFCore.Class("Animal") {

                        RDFCore.Label(missingLabel)
                    }
            """,
            "#sourceLocation()",
        ])
    }
}
