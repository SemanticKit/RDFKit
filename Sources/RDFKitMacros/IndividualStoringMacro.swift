import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// The extension macro on the storing protocol `@Ontology` generates for a
/// property, `Fauna.hasHabitatStoring`.
///
/// The protocol restates the property's requirement. This macro gives it
/// accessors that read and change the property's value,
/// `Fauna.hasHabitatValue`, in the individual's ``RDFCore/IndividualStorage``,
/// under its lock; a change in place holds the lock from the read to the
/// write. The storing protocol of
/// every domain of the property refines this one, so the property has one
/// pair of accessors however many of its domains an individual is in.
public struct IndividualStoringMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let storing = declaration.as(ProtocolDeclSyntax.self), storing.name.text.hasSuffix("Storing") else {
            throw MacroError("@IndividualStoring applies to the storing protocol @Ontology generates")
        }
        // The value type sits beside the storing protocol:
        // `Fauna.hasHabitatStoring` keeps its values in `Fauna.hasHabitatValue`.
        let valueName = String(storing.name.text.dropLast("Storing".count)) + "Value"
        let value: ExprSyntax = if let member = type.as(MemberTypeSyntax.self) {
            ExprSyntax.type(member.baseType.trimmed).member(.identifier(valueName))
        } else {
            ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(valueName)))
        }
        // `storage[Fauna.hasHabitatValue.self].value`
        let stored = ExprSyntax.named("storage").subscripted(value.dotSelf).member("value")
        // The accessors are as visible as the protocol, which is as visible
        // as the ontology that declares it.
        let access = DeclModifierListSyntax(storing.modifiers.filter { [.keyword(.public), .keyword(.package)].contains($0.name.tokenKind) }.map(\.trimmed))
        let accessors = storing.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }.compactMap { variable -> DeclSyntax? in
            guard let binding = variable.bindings.first,
                  let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
                  let type = binding.typeAnnotation?.type else { return nil }
            func accessor(_ specifier: Keyword, _ statement: CodeBlockItemSyntax.Item) -> AccessorDeclSyntax {
                AccessorDeclSyntax(accessorSpecifier: .keyword(specifier), body: CodeBlockSyntax([statement]))
            }
            return DeclSyntax(VariableDeclSyntax(
                modifiers: access,
                .var,
                name.trimmed,
                type: type.trimmed,
                accessors: AccessorBlockSyntax(accessors: .accessors(AccessorDeclListSyntax([
                    accessor(.get, .expr(stored)),
                    accessor(.set, .expr(stored.assigned(ExprSyntax.named("newValue")))),
                    accessor(._modify, .stmt(StmtSyntax(YieldStmtSyntax(yieldedExpressions: .single(ExprSyntax(InOutExprSyntax(expression: stored))))))),
                ])))
            ))
        }
        guard !accessors.isEmpty else { return [] }
        return [ExtensionDeclSyntax(extendedType: type.trimmed, memberBlock: MemberBlockSyntax(spaced: accessors))]
    }
}
