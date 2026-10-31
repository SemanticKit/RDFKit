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
/// `owl:Thing` is the same root (D7), so it names `RDFS.Resource`, and
/// `owl:Nothing`, the empty class, names `Never`:
///
///     public typealias Thing = RDFS.Resource
///     public typealias Nothing = Never
struct ClassGenerator {
    static let rdfs = "http://www.w3.org/2000/01/rdf-schema#"
    static let owl = "http://www.w3.org/2002/07/owl#"
    static let rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"

    static func generate(class entity: ParsedEntity, in ontology: ParsedOntology) -> DeclSyntax {
        if ontology.namespace == owl, let aliased = ["Thing": "RDFS.Resource", "Nothing": "Never"][entity.name] {
            return DeclSyntax(TypeAliasDeclSyntax(
                leadingTrivia: documentation(of: entity),
                modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                name: .identifier(entity.name),
                initializer: TypeInitializerClauseSyntax(value: TypeSyntax(stringLiteral: aliased))
            ))
        }
        let isRoot = ontology.namespace == rdfs && entity.name == "Resource"
        let superclasses = entity.annotations.filter { $0.name == "SubClassOf" }.map(\.value)
        let isLiteral = (ontology.namespace == rdfs && entity.name == "Literal") || superclasses.contains("RDFS.Literal")
        var inherited = isRoot ? [] : (superclasses.isEmpty ? ["RDFS.Resource"] : superclasses)
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
    static func documentation(of entity: ParsedEntity) -> Trivia {
        var lines: [String] = []
        if let comment = entity.annotations.first(where: { $0.name == "Comment" }) {
            lines.append(comment.value)
        }
        if let label = entity.annotations.first(where: { $0.name == "Label" }) {
            if !lines.isEmpty { lines.append("") }
            lines.append("Label: \(label.value)")
        }
        return Trivia(pieces: lines.flatMap { line in
            [TriviaPiece.docLineComment(line.isEmpty ? "///" : "/// \(line)"), .newlines(1)]
        })
    }
}
