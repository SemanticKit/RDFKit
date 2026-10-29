import SwiftSyntax
import SwiftSyntaxMacros

/// The extension macro on each class protocol `@Ontology` generates.
///
/// A class protocol `Q.N` requires its properties, and `@Ontology` generates
/// a property set `Q.NProperties` that holds their values. This macro
/// implements each property on that set, inside the individual's
/// `individualProperties`:
///
///     extension Fauna.Animal {
///         public var hasHabitat: RDFCore.PropertyValues<any Fauna.Habitat> {
///             individualProperties[\Fauna.AnimalProperties.hasHabitat]
///         }
///     }
///
/// Because an extension implements the requirements, a class that refines
/// another ontology's class (`OWL.Class` refining `RDFS.Class`) has
/// individuals without knowing that class's properties: `RDFS.Class`'s own
/// extension implements `subClassOf`. Each requirement has one
/// implementation, so an individual of several classes that share an
/// ancestor stores each of the ancestor's properties once.
///
/// The ontology's extension point `Q.Extending` names, as one type alias per
/// property, the properties the ontology declares for other ontologies'
/// classes:
///
///     typealias _equivalentClass = (any RDFS.Class, RDFCore.PropertyValues<any RDFS.Class>)
///
/// The alias is the property's domain and storage. This macro makes each a
/// member of the extension point wherever the individual is in the domain,
/// `extension OWL.Extending where Self: RDFS.Class`, stored in
/// `Q.ExtendingProperties`.
public struct ClassProtocolMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) else {
            throw MacroError("@ClassProtocol can only be applied to the class protocols @Ontology generates")
        }
        let extended = type.trimmedDescription
        let set = extended + "Properties"

        // The implementations are as visible as the protocol they implement.
        let access = protocolDeclaration.modifiers
            .map(\.name.text)
            .first { ["public", "package"].contains($0) }
            .map { $0 + " " } ?? ""

        var requirements: [String] = []
        var constrained: [(domain: String, members: [String])] = []
        for member in protocolDeclaration.memberBlock.members {
            if let variable = member.decl.as(VariableDeclSyntax.self) {
                for binding in variable.bindings {
                    guard let annotation = binding.typeAnnotation else { continue }
                    let name = binding.pattern.trimmedDescription
                    requirements.append(accessor(
                        documentation: variable.leadingTrivia,
                        access: access,
                        name: name,
                        type: annotation.type.trimmedDescription,
                        set: set
                    ))
                }
            } else if let alias = member.decl.as(TypeAliasDeclSyntax.self),
                      alias.name.text.hasPrefix("_"),
                      let tuple = alias.initializer.value.as(TupleTypeSyntax.self),
                      tuple.elements.count == 2 {
                let elements = Array(tuple.elements)
                var domain = elements[0].type.trimmedDescription
                if let some = elements[0].type.as(SomeOrAnyTypeSyntax.self) {
                    domain = some.constraint.trimmedDescription
                }
                let property = accessor(
                    documentation: alias.leadingTrivia,
                    access: access,
                    name: String(alias.name.text.dropFirst()),
                    type: elements[1].type.trimmedDescription,
                    set: set
                )
                if let index = constrained.firstIndex(where: { $0.domain == domain }) {
                    constrained[index].members.append(property)
                } else {
                    constrained.append((domain, [property]))
                }
            }
        }

        var sources: [DeclSyntax] = []
        if !requirements.isEmpty {
            sources.append("""
            extension \(raw: extended) {
            \(raw: requirements.joined(separator: "\n\n"))
            }
            """)
        }
        for (domain, members) in constrained {
            sources.append("""
            extension \(raw: extended) where Self: \(raw: domain) {
            \(raw: members.joined(separator: "\n\n"))
            }
            """)
        }
        return sources.map { $0.cast(ExtensionDeclSyntax.self) }
    }

    /// A property implemented on the set that stores it, with the
    /// documentation of the declaration it came from.
    private static func accessor(documentation: Trivia, access: String, name: String, type: String, set: String) -> String {
        let comment = documentation.compactMap { piece -> String? in
            if case .docLineComment(let line) = piece { return "    " + line }
            return nil
        }
        return (comment.isEmpty ? "" : comment.joined(separator: "\n") + "\n") + """
            \(access)var \(name): \(type) {
                individualProperties[\\\(set).\(name)]
            }
        """
    }
}
