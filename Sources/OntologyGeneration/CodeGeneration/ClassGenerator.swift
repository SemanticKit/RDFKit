import SwiftSyntax
import SwiftSyntaxBuilder

/// Generates the protocol a class declares (D1): its subclasses' protocols
/// inherit it (`rdfs:subClassOf`), and its documentation comes from its
/// label and comment (D8).
///
///     /// The class of classes.
///     ///
///     /// Label: Class
///     public protocol Class: RDFS.Resource, AnyObject {}
///
/// `rdfs:Resource` is the root (D7), and inherits nothing, because a literal
/// is a Swift value type (D6). Every other class's members are individuals,
/// instances of generated classes whose identity is the object's (D3), so its
/// protocol also inherits `AnyObject` and `alice.knows.contains { $0 === bob }`
/// compiles; `rdfs:Literal` and its subclasses do not. A class that states no
/// superclass is a subclass of `rdfs:Resource` (RDF 1.2 Semantics, rdfs8).
///
/// A class whose extension is the universe is the root (D7), so it names it,
/// and a class whose extension is empty names `Never`, as OWL 2 RDF-Based
/// Semantics §5.2 states (`owl:Thing ∈ IC, = IR`, `owl:Nothing ∈ IC, = ∅`):
///
///     public typealias Thing = RDFS.Resource
///     public typealias Nothing = Never
///
/// The root, the literal classes and the aliases are the ontology's
/// `schema`, which the published semantics entail.
public struct ClassGenerator {
    public static func generate(class entity: ParsedEntity, in ontology: ParsedOntology) -> DeclSyntax {
        let schema = ontology.schema
        let name = "\(ontology.name).\(entity.name)"
        if let aliased = schema.aliases[name] {
            return DeclSyntax(TypeAliasDeclSyntax(
                leadingTrivia: documentation(of: entity),
                modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                name: .identifier(entity.name),
                initializer: TypeInitializerClauseSyntax(value: TypeSyntax(stringLiteral: aliased))
            ))
        }
        let isRoot = name == schema.root
        let superclasses = entity.annotations.compactMap { $0.name == "SubClassOf" && $0.value != name ? $0.value : nil }
        let isLiteral = schema.literalClasses.contains(name) || !schema.literalClasses.isDisjoint(with: superclasses)
        var inherited = isRoot ? [] : (superclasses.isEmpty ? (schema.root.map { [$0] } ?? []) : superclasses)
        if !isRoot && !isLiteral { inherited.append("AnyObject") }

        let declaration = ProtocolDeclSyntax(
            leadingTrivia: documentation(of: entity),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            name: .identifier(entity.name),
            inheritanceClause: inherited.isEmpty ? nil : InheritanceClauseSyntax {
                for type in inherited {
                    InheritedTypeSyntax(type: TypeSyntax(stringLiteral: type))
                }
            },
            memberBlock: MemberBlockSyntax {
                for requirement in PropertyGenerator.requirements(of: entity, in: ontology) {
                    requirement
                }
            }
        )
        return DeclSyntax(declaration)
    }

    /// The comment as the abstract, then the label.
    public static func documentation(of entity: ParsedEntity) -> Trivia {
        var lines: [String] = []
        if let comment = entity.annotations.first(where: { $0.name == "Comment" }) {
            lines.append(comment.value)
        }
        if let label = entity.annotations.first(where: { $0.name == "Label" }) {
            if !lines.isEmpty { lines.append("") }
            lines.append("Label: \(label.value)")
        }
        for note in entity.annotations where note.name == "Annotation" {
            if !lines.isEmpty { lines.append("") }
            lines.append(note.value)
        }
        return Trivia(pieces: lines.flatMap { line in
            [TriviaPiece.docLineComment(line.isEmpty ? "///" : "/// \(line)"), .newlines(1)]
        })
    }
}
