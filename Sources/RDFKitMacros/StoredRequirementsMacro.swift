import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// The extension macro `@Ontology` attaches to every class protocol it
/// generates.
///
/// It implements each requirement of the protocol for
/// ``RDFCore/StoredIndividual``: the values live in the individual's
/// membership, under the requirement's own key path.
///
///     extension Fauna.Animal where Self: RDFCore.StoredIndividual {
///         public var hasHabitat: RDFCore.PropertyValues<any Fauna.Habitat> {
///             RDFCore.PropertyValues(\Self.hasHabitat, of: membership)
///         }
///     }
///
/// The requirements are read from the protocol itself, so an individual type
/// in any module that conforms to a class protocol, directly or through a
/// subclass, has every requirement of it, including those of classes the
/// module never sees declared.
public struct StoredRequirementsMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard declaration.is(ProtocolDeclSyntax.self) else {
            throw MacroError("@StoredRequirements applies to a class protocol that @Ontology generates")
        }
        let implementations = declaration.memberBlock.members.compactMap { member -> String? in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  let binding = variable.bindings.first,
                  let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let valueType = binding.typeAnnotation?.type else { return nil }
            let view = valueType.trimmedDescription
            guard let form = ["RDFCore.PropertyValues", "RDFCore.PropertyValue"].first(where: { view.hasPrefix($0 + "<") }) else {
                return nil
            }
            let documentation = variable.leadingTrivia.description
                .split(separator: "\n", omittingEmptySubsequences: true)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0.hasPrefix("///") }
                .map { "    " + $0 + "\n" }
                .joined()
            return """
            \(documentation)    public var \(name): \(view) {
                    \(form)(\\Self.\(name), of: membership)
                }
            """
        }
        guard !implementations.isEmpty else { return [] }
        let source: DeclSyntax = """
            extension \(type.trimmed) where Self: RDFCore.StoredIndividual {
            \(raw: implementations.joined(separator: "\n\n"))
            }
            """
        return [source.cast(ExtensionDeclSyntax.self)]
    }
}
