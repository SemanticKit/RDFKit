import SwiftParser
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import RDFKitMacros

@Suite("@OntologyContent body rewrite", .tags(.ontology))
struct OntologyContentMacroTests {
    @Test("A related type becomes the annotation type for that term")
    func rewritesTermAnnotations() {
        assertExpansion(
            """
            @OntologyContent
            func content() -> Content {
                Namespace("https://zoo.example.org/#")
                Class("Animal") {
                    Type(RDFS.Class)
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
            func content() -> Content {
                Namespace("https://zoo.example.org/#")
                RDFCore.Class("Animal") {
                        RDF.type<RDFS.Class>()
                        RDFS.label("Animal")
                        Endangered(Zoo.Animal)
                    }
                RDFCore.Class("Keeper") {
                        RDFS.subClassOf<Animal>()
                        RDFS.label(keeperLabel)
                    }
                if includeVets {
                        RDFCore.Property("treats") {
                            RDFS.domain<Zoo.Vet>()
                            RDFS.range<Zoo.Animal>()
                        }
                    }
            }
            """
        )
    }

    @Test("Generic and .self spellings are reported with a fix-it")
    func diagnosesOtherSpellings() {
        assertExpansion(
            """
            @OntologyContent
            func content() -> Content {
                Class("Animal") {
                    SubClassOf<Zoo.Animal>()
                    Domain(Zoo.Animal.self)
                }
            }
            """,
            expandedSource: """
            func content() -> Content {
                RDFCore.Class("Animal") {
                        SubClassOf<Zoo.Animal>()
                        Domain(Zoo.Animal.self)
                    }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Write SubClassOf with the related type as its argument: SubClassOf(Zoo.Animal)",
                    line: 4, column: 9,
                    fixIts: [FixItSpec(message: "Write SubClassOf(Zoo.Animal)")]
                ),
                DiagnosticSpec(
                    message: "Write Domain with the related type as its argument: Domain(Zoo.Animal)",
                    line: 5, column: 9,
                    fixIts: [FixItSpec(message: "Write Domain(Zoo.Animal)")]
                ),
            ],
            applyFixIts: ["Write SubClassOf(Zoo.Animal)", "Write Domain(Zoo.Animal)"],
            fixedSource: """
            @OntologyContent
            func content() -> Content {
                Class("Animal") {
                    SubClassOf(Zoo.Animal)
                    Domain(Zoo.Animal)
                }
            }
            """
        )
    }

    @Test("Each statement keeps the line it was authored on")
    func keepsAuthoredLines() throws {
        let source: SourceFileSyntax = """
            struct Zoo {
                @OntologyContent
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")

                    Class("Animal") {
                        Type(RDFS.Clas)
                    }
                }
            }
            """
        let function = try #require(source.statements.first?.item.as(StructDeclSyntax.self)?
            .memberBlock.members.first?.decl.as(FunctionDeclSyntax.self))
        let attribute = try #require(function.attributes.first?.as(AttributeSyntax.self))
        let context = BasicMacroExpansionContext(
            sourceFiles: [source: .init(moduleName: "Zoo", fullFilePath: "/Zoo/Zoo.swift")]
        )

        let body = try OntologyContentMacro.expansion(of: attribute, providingBodyFor: function, in: context)

        #expect(body.map(\.trimmedDescription) == [
            #"#sourceLocation(file: "/Zoo/Zoo.swift", line: 4)"#,
            #"Namespace("https://zoo.example.org/#")"#,
            #"#sourceLocation(file: "/Zoo/Zoo.swift", line: 6)"#,
            """
            RDFCore.Class("Animal") {
                        RDF.type<RDFS.Clas>()
                    }
            """,
            "#sourceLocation()",
        ])
    }
}
