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

        let declaredNames = Self.declaredNames(in: statements)
        var namespace: String?
        var declarations: [ParsedEntity] = []

        for statement in statements {
            guard let expression = statement.item.as(ExprSyntax.self),
                  let call = DeclarationCall(expression, declaredNames: declaredNames) else { continue }

            if call.name == "Namespace" {
                namespace = namespace ?? call.stringArgument
                continue
            }
            guard let kind = ParsedEntity.Kind(rawValue: call.name),
                  let name = call.stringArgument, !name.isEmpty else { continue }

            declarations.append(
                ParsedEntity(
                    name: name,
                    kind: kind,
                    annotations: AnnotationParser.parse(from: call.call, declaredNames: declaredNames),
                    syntax: Syntax(call.call)
                )
            )
        }

        guard let namespace, !namespace.isEmpty else {
            throw MacroError("Content must include a Namespace(\"...\") declaration")
        }

        let access = structDecl.modifiers
            .map(\.name.text)
            .first { ["public", "package"].contains($0) }
            .map { $0 + " " } ?? ""
        return ParsedOntology(
            typeName: structDecl.name.text,
            namespace: namespace,
            access: access,
            declarations: declarations
        )
    }

    /// The local names of the terms declared at the top level of a content
    /// body: `Animal` for `Class("Animal")`.
    static func declaredNames(in statements: CodeBlockItemListSyntax) -> Set<String> {
        var names: Set<String> = []
        for statement in statements {
            guard let expression = statement.item.as(ExprSyntax.self),
                  let call = DeclarationCall(expression, declaredNames: []),
                  ParsedEntity.Kind(rawValue: call.name) != nil,
                  let name = call.stringArgument else { continue }
            names.insert(name)
        }
        return names
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
