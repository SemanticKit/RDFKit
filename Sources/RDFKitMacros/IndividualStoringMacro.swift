import SwiftSyntax
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
        let storingType = type.trimmedDescription
        let valueType = String(storingType.dropLast("Storing".count)) + "Value"
        // The accessors are as visible as the protocol, which is as visible
        // as the ontology that declares it.
        let access = storing.modifiers
            .first { [.keyword(.public), .keyword(.package)].contains($0.name.tokenKind) }
            .map { $0.name.text + " " } ?? ""
        let accessors = storing.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }.compactMap { variable -> String? in
            guard let binding = variable.bindings.first,
                  let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let type = binding.typeAnnotation?.type.trimmedDescription else { return nil }
            return """
                \(access)var \(name): \(type) {
                    get { storage[\(valueType).self].value }
                    set { storage[\(valueType).self].value = newValue }
                    _modify { yield &storage[\(valueType).self].value }
                }
            """
        }
        guard !accessors.isEmpty else { return [] }
        let source: DeclSyntax = """
        extension \(raw: storingType) {
        \(raw: accessors.joined(separator: "\n\n"))
        }
        """
        return [source.cast(ExtensionDeclSyntax.self)]
    }
}
