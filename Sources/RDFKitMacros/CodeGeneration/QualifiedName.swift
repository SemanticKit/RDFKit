import SwiftSyntax

/// A Swift name qualified by the types that contain it, `Fauna.Animal`, kept
/// as its components so the generated syntax is built from tokens, never
/// from source text.
struct QualifiedName: Equatable {
    /// The names, outermost first: `["Fauna", "Animal"]`.
    let components: [String]

    init(_ components: [String]) {
        self.components = components
    }

    init(_ components: String...) {
        self.components = components
    }

    /// The name a term spelling gives, `Fauna.Animal` or ``Fauna.`Type` ``:
    /// the identifiers between its dots, without backticks.
    init(spelling: String) {
        components = spelling.split(separator: ".").map { $0.trimmingCharacters(in: ["`", " "]) }
    }

    /// The innermost name, `Animal`.
    var name: String { components.last ?? "" }

    /// The name of the type that contains this one, `Fauna`, if any.
    var qualifier: QualifiedName? {
        components.count > 1 ? QualifiedName(Array(components.dropLast())) : nil
    }

    /// The name of a member of the named type: `Fauna.Animal.Member`.
    func appending(_ member: String) -> QualifiedName {
        QualifiedName(components + [member])
    }

    /// The name with its innermost component replaced: `Fauna.AnimalIndividual`
    /// for `Fauna.Animal`.
    func replacingName(with name: String) -> QualifiedName {
        QualifiedName(Array(components.dropLast()) + [name])
    }

    /// The type this name refers to: `Fauna.Animal` as a `MemberTypeSyntax`.
    var type: TypeSyntax {
        var result = TypeSyntax(IdentifierTypeSyntax(name: .declared(components[0])))
        for component in components.dropFirst() {
            result = TypeSyntax(MemberTypeSyntax(baseType: result, name: .declared(component)))
        }
        return result
    }

    /// The type as an expression: `Fauna.Animal` as a `MemberAccessExprSyntax`.
    var expression: ExprSyntax {
        var result = ExprSyntax(DeclReferenceExprSyntax(baseName: .declared(components[0])))
        for component in components.dropFirst() {
            result = result.member(component)
        }
        return result
    }
}

extension TokenSyntax {
    /// The identifier of a declared name, sanitized and in backticks when it
    /// is a keyword: `` `class` ``, `version_1_0`.
    static func declared(_ name: String) -> TokenSyntax {
        .identifier(SwiftIdentifier.escaped(name))
    }
}
