import SwiftSyntax
import SwiftSyntaxMacros

/// The extension macro on each class protocol `@Ontology` generates.
///
/// A class protocol requires its properties and one accessor per class whose
/// values an individual of it stores: its own (`_withFauna_PredatorValues`)
/// and its ancestors' (`_withFauna_AnimalValues`). This macro implements the
/// properties on the class's own values and each ancestor's accessor on that
/// ancestor's slot inside them, so an individual type only implements the
/// class's own accessor.
///
/// Because an extension can implement another ontology's requirements, a
/// class that refines another ontology's class (`OWL.Class` refining
/// `RDFS.Class`) has individuals too: `RDFS.Class`'s own extension
/// implements `subClassOf` on `RDFS.ClassValues`, which `OWL.ClassValues`
/// keeps in its `_RDFS_Class` slot. When two classes on an individual's path
/// both implement an accessor, Swift uses the more refined one, so every path
/// reaches the same slot.
public struct ClassProtocolMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard declaration.is(ProtocolDeclSyntax.self) else {
            throw MacroError("@ClassProtocol can only be applied to the class protocols @Ontology generates")
        }
        let accessors = declaration.memberBlock.members.compactMap { member in
            member.decl.as(FunctionDeclSyntax.self).flatMap(storage(accessedBy:))
        }
        // The class's own accessor: the one for the extended type when it is
        // written with its ontology (`Fauna.Animal`), otherwise the first one
        // for a class of the protocol's name, which `@Ontology` declares first.
        let protocolName = declaration.as(ProtocolDeclSyntax.self)?.name.text ?? ""
        let qualified = ClassStorage(spelling: type.trimmedDescription)
        let ownAccessor = accessors.first { storage in
            if let qualified { return storage == qualified }
            return storage.localValuesName == protocolName + "Values"
        }
        guard let own = ownAccessor else {
            throw MacroError("@ClassProtocol needs the accessor of the class's own values, as @Ontology declares it")
        }

        // The implementations are as visible as the protocol they implement.
        let access = declaration.modifiers
            .map(\.name.text)
            .first { ["public", "package"].contains($0) }
            .map { $0 + " " } ?? ""
        var members: [String] = []
        for member in declaration.memberBlock.members {
            if let variable = member.decl.as(VariableDeclSyntax.self) {
                for binding in variable.bindings {
                    guard let annotation = binding.typeAnnotation else { continue }
                    let name = binding.pattern.trimmedDescription
                    members.append("""
                        \(access)var \(name): \(annotation.type.trimmedDescription) {
                            get { \(own.accessor) { $0.\(name) } }
                            set { \(own.accessor) { $0.\(name) = newValue } }
                        }
                    """)
                }
            } else if let function = member.decl.as(FunctionDeclSyntax.self),
                      function.name.text != own.accessor,
                      let ancestor = storage(accessedBy: function) {
                members.append("""
                    \(access)\(ancestor.accessorSignature) {
                        \(own.accessor) { body(&$0.\(ancestor.slot)) }
                    }
                """)
            }
        }
        guard !members.isEmpty else { return [] }

        let source: DeclSyntax = """
        extension \(raw: type.trimmedDescription) {
        \(raw: members.joined(separator: "\n\n"))
        }
        """
        return [source.cast(ExtensionDeclSyntax.self)]
    }

    /// The class whose values a requirement such as
    /// `func _withFauna_AnimalValues<Result: Sendable>(_ body: (inout Fauna.AnimalValues) -> Result) -> Result`
    /// reads, from the values type of its `body` parameter.
    private static func storage(accessedBy function: FunctionDeclSyntax) -> ClassStorage? {
        guard let parameter = function.signature.parameterClause.parameters.first,
              let closure = parameter.type.as(FunctionTypeSyntax.self),
              let argument = closure.parameters.first,
              let attributed = argument.type.as(AttributedTypeSyntax.self) else { return nil }
        let storage = ClassStorage(valuesType: attributed.baseType.trimmedDescription)
        return storage?.accessor == function.name.text ? storage : nil
    }
}
