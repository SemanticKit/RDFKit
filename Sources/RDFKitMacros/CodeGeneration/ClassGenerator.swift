import SwiftSyntax
import SwiftSyntaxBuilder

/// Generates the protocol a class declares (D1): its subclasses' protocols
/// inherit it (`rdfs:subClassOf`), and its documentation comes from its
/// label and comment (D8).
///
///     /// The class of classes.
///     ///
///     /// Label: Class
///     public protocol Class: RDFS.Resource {}
///
/// `rdfs:Resource` is the root (D7), and inherits nothing: a literal is a
/// Swift value type (D6) and an individual an instance of a generated class,
/// whose identity is the object's (D3). A class that states no superclass is
/// a subclass of `rdfs:Resource` (RDF 1.2 Semantics, rdfs8).
struct ClassGenerator {
    static let rdfs = "http://www.w3.org/2000/01/rdf-schema#"

    static func generate(class entity: ParsedEntity, in ontology: ParsedOntology) -> DeclSyntax {
        let isRoot = ontology.namespace == rdfs && entity.name == "Resource"
        let superclasses = entity.annotations.filter { $0.name == "SubClassOf" }.map(\.value)
        let inherited = isRoot ? [] : (superclasses.isEmpty ? ["RDFS.Resource"] : superclasses)

        let declaration = ProtocolDeclSyntax(
            leadingTrivia: documentation(of: entity),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            name: .identifier(entity.name),
            inheritanceClause: inherited.isEmpty ? nil : InheritanceClauseSyntax {
                for type in inherited {
                    InheritedTypeSyntax(type: TypeSyntax(stringLiteral: type))
                }
            },
            memberBlock: MemberBlockSyntax {}
        )
        return DeclSyntax(declaration)
    }

    /// The comment as the abstract, then the label.
    private static func documentation(of entity: ParsedEntity) -> Trivia {
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
