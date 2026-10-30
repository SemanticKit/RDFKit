import SwiftSyntax

/// Reads the ontology DSL from the `var body` of an `@Ontology` struct.
struct OntologyParser {
    static func parse(declaration: some DeclGroupSyntax) throws -> ParsedOntology {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError("@Ontology can only be applied to structs")
        }
        guard let statements = bodyProperty(in: declaration).flatMap(bodyStatements(of:)) else {
            throw MacroError("@Ontology requires a 'var body: some Content' with a body")
        }

        let declaredNames = Self.declaredNames(in: statements)
        var namespace: String?
        var declarations: [ParsedEntity] = []
        var redeclarations: [ParsedOntology.Redeclaration] = []

        for statement in statements {
            guard let expression = statement.item.as(ExprSyntax.self),
                  let call = DeclarationCall(expression, declaredNames: declaredNames) else { continue }

            if call.name == "Namespace" {
                namespace = namespace ?? call.stringArgument
                continue
            }
            guard let kind = ParsedEntity.Kind(rawValue: call.name),
                  let name = call.stringArgument, !name.isEmpty else { continue }

            let declaration = ParsedEntity(
                name: name,
                kind: kind,
                annotations: AnnotationParser.parse(from: call.call, declaredNames: declaredNames),
                syntax: Syntax(call.call)
            )
            // An RDF graph is a set of triples (RDF 1.2 Concepts, RDF
            // Graphs): what a later declaration of the same term states is
            // stated about that one term.
            guard let index = declarations.firstIndex(where: { $0.name == name }) else {
                declarations.append(declaration)
                continue
            }
            if declarations[index].kind == kind {
                declarations[index] = declarations[index].merging(declaration)
            } else {
                redeclarations.append(.init(declaration: declaration, firstKind: declarations[index].kind))
            }
        }

        guard let namespace, !namespace.isEmpty else {
            throw MacroError("Content must include a Namespace(\"...\") declaration")
        }

        return ParsedOntology(
            typeName: structDecl.name.text,
            access: structDecl.modifiers
                .map(\.name.tokenKind)
                .first { [.keyword(.public), .keyword(.open), .keyword(.package)].contains($0) }
                .map { $0 == .keyword(.package) ? "package " : "public " } ?? "",
            namespace: namespace,
            declarations: declarations,
            redeclarations: redeclarations
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

    /// The ontology's `var body: some Content`, whose body is the DSL.
    ///
    /// The body is read as syntax. `@Ontology` attaches the body macro
    /// `@OntologyContent` to this property, so the compiler never type-checks
    /// the authored statements themselves: `Domain(Fauna.Animal)` is read
    /// here and written as declarations, and the body macro returns the
    /// declarations with the annotations that carry text.
    static func bodyProperty(in declaration: some DeclGroupSyntax) -> VariableDeclSyntax? {
        declaration.memberBlock.members.lazy
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .first { isBodyProperty($0) }
    }

    /// A `content()` function member: ontology content written as a function,
    /// which `@Ontology` reports with a fix-it to `var body`.
    static func contentFunction(in declaration: some DeclGroupSyntax) -> FunctionDeclSyntax? {
        declaration.memberBlock.members.lazy
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .first { $0.name.text == "content" && $0.signature.parameterClause.parameters.isEmpty }
    }

    /// Whether a member is the get-only computed property `var body { ... }`,
    /// the form a body macro can own.
    static func isBodyProperty(_ variable: VariableDeclSyntax) -> Bool {
        guard variable.bindingSpecifier.tokenKind == .keyword(.var),
              variable.bindings.count == 1,
              let binding = variable.bindings.first,
              binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "body" else { return false }
        return bodyStatements(of: variable) != nil
    }

    /// The statements of the getter of `var body`.
    static func bodyStatements(of variable: VariableDeclSyntax) -> CodeBlockItemListSyntax? {
        guard case .getter(let statements) = variable.bindings.first?.accessorBlock?.accessors else { return nil }
        return statements
    }
}
