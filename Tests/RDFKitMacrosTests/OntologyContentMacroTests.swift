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
            var body: some Content {
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
            var body: some Content {
                Namespace("https://zoo.example.org/#")
                RDFCore.Class("Animal") {
                        Type<RDFS.Class>()
                        Label("Animal")
                        Endangered<Zoo.Animal>()
                    }
                RDFCore.Class("Keeper") {
                        SubClassOf<Animal>()
                        Label(keeperLabel)
                    }
                if includeVets {
                        RDFCore.Property("treats") {
                            Domain<Zoo.Vet>()
                            Range<Zoo.Animal>()
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
                        Type(RDFS.Clas)
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
            #"Namespace("https://zoo.example.org/#")"#,
            #"#sourceLocation(file: "/Zoo/Zoo.swift", line: 6)"#,
            """
            RDFCore.Class("Animal") {
                        Type<RDFS.Clas>()
                    }
            """,
            "#sourceLocation()",
        ])
    }
}
