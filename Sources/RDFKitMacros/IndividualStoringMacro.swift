import SwiftSyntax
import SwiftSyntaxMacros

/// The extension macro on the storing protocol `@Ontology` generates for a
/// class, `Fauna.AnimalStoring`.
///
/// The protocol restates the class's requirements and requires one method,
/// `withAnimalValues(_:)`, that reads or changes the class's property values,
/// ``Fauna/AnimalValues``, under the lock of the individual's
/// ``RDFCore/IndividualStorage``. This macro gives every restated requirement
/// the same accessors an individual type of the class has, through that
/// method, so an individual declared in another ontology or module that is
/// typed with the class conforms by storing its values.
public struct IndividualStoringMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let storing = declaration.as(ProtocolDeclSyntax.self) else {
            throw MacroError("@IndividualStoring applies to the storing protocol @Ontology generates")
        }
        let members = storing.memberBlock.members.map(\.decl)
        guard let method = members.lazy.compactMap({ $0.as(FunctionDeclSyntax.self) }).first?.name.text else {
            throw MacroError("@IndividualStoring requires the protocol's values method")
        }
        let accessors = members.compactMap { $0.as(VariableDeclSyntax.self) }.compactMap { variable -> String? in
            guard let binding = variable.bindings.first,
                  let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let type = binding.typeAnnotation?.type.trimmedDescription else { return nil }
            return """
                public var \(name): \(type) {
                    get { \(method) { $0.\(name) } }
                    set { \(method) { $0.\(name) = newValue } }
                }
            """
        }
        guard !accessors.isEmpty else { return [] }
        let source: DeclSyntax = """
        extension \(type.trimmed) {
        \(raw: accessors.joined(separator: "\n\n"))
        }
        """
        return [source.cast(ExtensionDeclSyntax.self)]
    }
}
