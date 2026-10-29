import SwiftSyntax

/// Reads the ontology DSL from the `content()` function of an `@Ontology` struct.
struct OntologyParser {
    static func parse(declaration: some DeclGroupSyntax) throws -> ParsedOntology {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError("@Ontology can only be applied to structs")
        }
        guard let statements = contentFunction(in: declaration)?.body?.statements else {
            throw MacroError("@Ontology requires a 'func content() -> Content' with a body")
        }

        var namespace: String?
        var declarations: [ParsedEntity] = []

        for statement in statements {
            guard let expression = statement.item.as(ExprSyntax.self),
                  let call = try DeclarationCall(expression) else { continue }

            if call.name == "Namespace" {
                namespace = namespace ?? call.stringArgument
                continue
            }
            guard let kind = ParsedEntity.Kind(rawValue: call.name),
                  let name = call.stringArgument, !name.isEmpty else { continue }

            declarations.append(
                ParsedEntity(name: name, kind: kind, annotations: try AnnotationParser.parse(from: call.call))
            )
        }

        guard let namespace, !namespace.isEmpty else {
            throw MacroError("Content must include a Namespace(\"...\") declaration")
        }

        return ParsedOntology(
            typeName: structDecl.name.text,
            namespace: namespace,
            declarations: declarations
        )
    }

    /// The ontology's `func content() -> Content`, whose body is the DSL.
    ///
    /// The body is read as syntax. `@Ontology` attaches the body macro
    /// `@OntologyContent` to this function, so the compiler never type-checks
    /// the authored statements themselves: `Domain(Fauna.Animal)` is read
    /// here, and the body macro emits the content built from the generated
    /// types.
    static func contentFunction(in declaration: some DeclGroupSyntax) -> FunctionDeclSyntax? {
        declaration.memberBlock.members.lazy
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .first { isContentFunction($0) }
    }

    /// Whether a member is `func content()` with no parameters.
    static func isContentFunction(_ function: FunctionDeclSyntax) -> Bool {
        function.name.text == "content" && function.signature.parameterClause.parameters.isEmpty
    }
}
