import SwiftSyntax
import SwiftSyntaxMacros

/// The extension macro `@Ontology` attaches to every class protocol it
/// generates.
///
/// Each requirement of a class protocol is a subscript keyed by a property's
/// term type: `subscript(property: Fauna.hasHabitat) -> [any Fauna.Habitat]`.
/// The macro gives each one a default implementation that keeps the values in
/// the individual's ``RDFCore/IndividualStorage`` under that term type, and a
/// member named after the property, `animal.hasHabitat`, that reads and writes
/// through it. So an individual type of any ontology conforms to the class
/// protocol without knowing its requirements: `Foaf.PersonIndividual`
/// conforms to `Geo.SpatialThing`, whose requirements the FOAF ontology does
/// not declare.
///
/// The named member is not a requirement, so it never answers for another
/// ontology's requirement. When a class `X.C` refines another ontology's class
/// `Y.Q` and both ontologies declare a property `name`, `X.C` and `Y.Q` each
/// have their own `name` member and their own subscript requirement, keyed
/// by `X.name` and `Y.name`: reading `name` through `any Y.Q` reads the
/// values of `Y.name`, and through `any X.C` those of `X.name`.
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

        let requirements = protocolDecl.memberBlock.members.compactMap { $0.decl.as(SubscriptDeclSyntax.self) }
        if requirements.isEmpty { return [] }
        let members = try requirements.map { requirement -> String in
            guard requirement.parameterClause.parameters.count == 1,
                  let parameter = requirement.parameterClause.parameters.first else {
                throw MacroError("A class protocol requirement is a subscript keyed by one property term")
            }
            let key = parameter.type.trimmedDescription
            let valueType = requirement.returnClause.type.trimmedDescription
            let documentation = requirement.leadingTrivia.compactMap { piece -> String? in
                if case .docLineComment(let line) = piece { return "    \(line)\n" }
                return nil
            }.joined()
            return """
                \(access)subscript(property: \(key)) -> \(valueType) {
                    get { propertyValues[property] }
                    set { propertyValues[property] = newValue }
                }

            \(documentation)    \(access)var \(memberName(ofKey: key)): \(valueType) {
                    get { self[\(key)()] }
                    set { self[\(key)()] = newValue }
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

    /// The member name of the property a key type keeps: `hasHabitat` for
    /// `Fauna.hasHabitat`, and `subClassOf` for the values key
    /// `RDFS._subClassOfValues` of a property whose term is an RDFCore alias.
    private static func memberName(ofKey key: String) -> String {
        let name = key.lastIndex(of: ".").map { String(key[key.index(after: $0)...]) } ?? key
        let prefix = "_", suffix = "Values"
        guard name.hasPrefix(prefix), name.hasSuffix(suffix),
              BootstrapTerm.valuesKey(of: String(name.dropFirst(prefix.count).dropLast(suffix.count))) == name else {
            return name
        }
        return SwiftIdentifier.escaped(String(name.dropFirst(prefix.count).dropLast(suffix.count)))
    }
}
