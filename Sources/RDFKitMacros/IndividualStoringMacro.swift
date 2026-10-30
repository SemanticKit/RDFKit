import SwiftSyntax
import SwiftSyntaxMacros

/// The extension macro on the storing protocol `@Ontology` generates for a
/// class, `Fauna.AnimalStoring`.
///
/// The protocol restates the requirements of the class's own properties,
/// those whose domain is the class. This macro gives each one accessors that
/// read and change the class's values, `Fauna.AnimalValues`, through
/// ``RDFCore/ClassValuesStoring/withClassValues(_:)``, under the lock of the
/// individual's ``RDFCore/IndividualStorage``. An individual declared in
/// another ontology or module that is typed with the class conforms by
/// storing its classes' values. The properties of a superclass are supplied
/// by the superclass's storing protocol, which this one refines, so each
/// property has one pair of accessors.
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
        let valuesType = String(storingType.dropLast("Storing".count)) + "Values"
        let accessors = storing.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }.compactMap { variable -> String? in
            guard let binding = variable.bindings.first,
                  let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let type = binding.typeAnnotation?.type.trimmedDescription else { return nil }
            return """
                public var \(name): \(type) {
                    get { withClassValues { (values: inout \(valuesType)) in values.\(name) } }
                    set { withClassValues { (values: inout \(valuesType)) in values.\(name) = newValue } }
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
