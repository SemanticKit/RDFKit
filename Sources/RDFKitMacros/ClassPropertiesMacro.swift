import SwiftSyntax
import SwiftSyntaxMacros

/// The extension macro `@Ontology` attaches to every class protocol it
/// generates.
///
/// It gives each property requirement of the protocol a default
/// implementation that keeps the values in the individual's
/// ``RDFCore/IndividualStorage``, under the property's term type. So an
/// individual type of any ontology conforms to the class protocol without
/// knowing its requirements: `Foaf.PersonIndividual` conforms to
/// `Geo.SpatialThing`, whose requirements the FOAF ontology does not declare.
///
/// The requirement `var hasHabitat: [any Fauna.Habitat] { get set }` of
/// `Fauna.Animal` is kept under the term type `Fauna.hasHabitat`: a
/// requirement has the name of its property, and the property term is a
/// member of the same ontology as the class.
public struct ClassPropertiesMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw MacroError("@ClassProperties applies to the class protocols @Ontology generates")
        }
        let access = protocolDecl.modifiers.contains { $0.name.tokenKind == .keyword(.public) } ? "public " : ""

        let requirements = protocolDecl.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        if requirements.isEmpty { return [] }
        guard let ontology = ontologyName(of: type, in: context) else {
            throw MacroError("@ClassProperties applies to a class protocol nested in its ontology")
        }
        let members = requirements.compactMap { variable -> String? in
            guard let binding = variable.bindings.first,
                  let valueType = binding.typeAnnotation?.type.trimmedDescription else { return nil }
            let name = binding.pattern.trimmedDescription
            let property = name.replacingOccurrences(of: "`", with: "")
            let key = BootstrapTerm.isAliasProperty("\(ontology).\(property)")
                ? "\(ontology).\(BootstrapTerm.valuesKey(of: property))()"
                : "\(ontology).\(name)()"
            return """
                \(access)var \(name): \(valueType) {
                    get { propertyValues[\(key)] }
                    set { propertyValues[\(key)] = newValue }
                }
            """
        }
        let source: DeclSyntax = """
        extension \(type.trimmed) {
        \(raw: members.joined(separator: "\n\n"))
        }
        """
        return [try ExtensionDeclSyntax(validating: source.cast(ExtensionDeclSyntax.self))]
    }

    /// The ontology the class protocol is nested in, `Fauna` for
    /// `Fauna.Animal`: the qualifier of the extended type, or the enclosing
    /// struct or extension.
    private static func ontologyName(of type: some TypeSyntaxProtocol, in context: some MacroExpansionContext) -> String? {
        let typeName = type.trimmedDescription
        if let dot = typeName.lastIndex(of: ".") { return String(typeName[..<dot]) }
        for scope in context.lexicalContext {
            if let ontology = scope.as(StructDeclSyntax.self) { return ontology.name.trimmedDescription }
            if let ontology = scope.as(ExtensionDeclSyntax.self) { return ontology.extendedType.trimmedDescription }
        }
        return nil
    }
}
