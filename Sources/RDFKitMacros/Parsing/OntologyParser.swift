import SwiftSyntax

/// Reads the ontology DSL from the `content` property of an `@Ontology` struct.
struct OntologyParser {
    static func parse(declaration: some DeclGroupSyntax) throws -> ParsedOntology {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError("@Ontology can only be applied to structs")
        }
        guard let contentBinding = findContentProperty(in: declaration),
              let accessorBlock = contentBinding.accessorBlock else {
            throw MacroError("@Ontology requires a 'var content: Content' computed property")
        }

        let statements: CodeBlockItemListSyntax
        switch accessorBlock.accessors {
        case .getter(let body):
            statements = body
        case .accessors(let accessors):
            guard let body = accessors.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.get) })?.body?.statements else {
                throw MacroError("Content property must have a body")
            }
            statements = body
        }

        var namespace: String?
        var declarations: [ParsedEntity] = []

        for statement in statements {
            guard let expression = statement.item.as(ExprSyntax.self),
                  let call = DeclarationCall(expression) else { continue }

            if call.name == "Namespace" {
                namespace = namespace ?? call.stringArgument
                continue
            }
            guard let kind = ParsedEntity.Kind(rawValue: call.name),
                  let name = call.stringArgument, !name.isEmpty else { continue }

            declarations.append(
                ParsedEntity(name: name, kind: kind, annotations: AnnotationParser.parse(from: call.call))
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

    private static func findContentProperty(in declaration: some DeclGroupSyntax) -> PatternBindingSyntax? {
        for member in declaration.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self) else { continue }
            for binding in variable.bindings {
                if binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "content" {
                    return binding
                }
            }
        }
        return nil
    }
}
