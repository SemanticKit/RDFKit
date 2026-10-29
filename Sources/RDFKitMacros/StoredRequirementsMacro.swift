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
///
/// An ontology's extension point `Q.Extending` names, as one type alias per
/// property, the properties the ontology declares for other ontologies'
/// classes:
///
///     typealias _equivalentClass = (any RDFS.Class, RDFCore.PropertyValues<any RDFS.Class>, OWL.equivalentClass)
///
/// The alias gives the property's domain, value view and term type. Each
/// becomes a member of the extension point wherever the individual is in
/// the domain, on the `membership` the extension point requires, so the
/// member is there on an existential (`any RDFS.Class`) too. Its values are
/// stored under the term type, which `OWL.equivalentClass.values(of:)` reads
/// as well:
///
///     extension OWL.Extending where Self: RDFS.Class {
///         public var equivalentClass: RDFCore.PropertyValues<any RDFS.Class> {
///             OWL.equivalentClass.propertyValues(in: membership)
///         }
///     }
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
        // The implementations are as visible as the protocol they implement.
        let access = declaration.modifiers
            .map(\.name.text)
            .first { ["public", "package"].contains($0) }
            .map { $0 + " " } ?? ""
        var implementations: [String] = []
        var constrained: [(domain: String, members: [String])] = []
        for member in declaration.memberBlock.members {
            if let variable = member.decl.as(VariableDeclSyntax.self),
               let binding = variable.bindings.first,
               let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
               let valueType = binding.typeAnnotation?.type,
               let implementation = implementation(of: name, view: valueType.trimmedDescription, documentation: variable.leadingTrivia, access: access) {
                implementations.append(implementation)
            } else if let alias = member.decl.as(TypeAliasDeclSyntax.self),
                      alias.name.text.hasPrefix("_"),
                      let tuple = alias.initializer.value.as(TupleTypeSyntax.self),
                      tuple.elements.count == 3 {
                let elements = Array(tuple.elements)
                let domainType = elements[0].type
                let domain = domainType.as(SomeOrAnyTypeSyntax.self)?.constraint.trimmedDescription ?? domainType.trimmedDescription
                guard let implementation = implementation(
                    of: String(alias.name.text.dropFirst()),
                    view: elements[1].type.trimmedDescription,
                    term: elements[2].type.trimmedDescription,
                    documentation: alias.leadingTrivia,
                    access: access
                ) else { continue }
                if let index = constrained.firstIndex(where: { $0.domain == domain }) {
                    constrained[index].members.append(implementation)
                } else {
                    constrained.append((domain, [implementation]))
                }
            }
        }

        var sources: [DeclSyntax] = []
        if !implementations.isEmpty {
            sources.append("""
                extension \(type.trimmed) where Self: RDFCore.StoredIndividual {
                \(raw: implementations.joined(separator: "\n\n"))
                }
                """)
        }
        for (domain, members) in constrained {
            sources.append("""
                extension \(type.trimmed) where Self: \(raw: domain) {
                \(raw: members.joined(separator: "\n\n"))
                }
                """)
        }
        return sources.map { $0.cast(ExtensionDeclSyntax.self) }
    }

    /// A property implemented on the individual's membership, under its own
    /// key path, with the documentation of the declaration it came from.
    private static func implementation(of name: String, view: String, term: String? = nil, documentation trivia: Trivia, access: String) -> String? {
        guard let form = ["RDFCore.PropertyValues", "RDFCore.PropertyValue"].first(where: { view.hasPrefix($0 + "<") }) else {
            return nil
        }
        let documentation = trivia.description
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.hasPrefix("///") }
            .map { "    " + $0 + "\n" }
            .joined()
        // A property of another ontology's class is stored under its term
        // type, which the term type's own accessor reads too.
        let body = term.map { "\($0).\(form == "RDFCore.PropertyValue" ? "propertyValue" : "propertyValues")(in: membership)" }
            ?? "\(form)(\\Self.\(name), of: membership)"
        return """
        \(documentation)    \(access)var \(name): \(view) {
                \(body)
            }
        """
    }
}
