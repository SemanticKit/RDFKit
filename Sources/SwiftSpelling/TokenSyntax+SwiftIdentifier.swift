import SwiftParser
import SwiftSyntax

extension TokenSyntax {
    /// The identifier `name`, in backticks where Swift requires them.
    ///
    /// SwiftParser decides, so the `@Ontology` macro and RDFTranslator spell
    /// every name the same way. Generated Swift names a term where it is
    /// declared, `protocol Animal`, after a dot in an expression,
    /// `Fauna.Animal.self`, and after a dot in a type, `any Fauna.Animal`. A
    /// name is written bare only when it parses as that identifier in all
    /// three. Every other name is in backticks: a keyword, `` `class` ``; a
    /// name that means something else after a dot, `` `self` ``, `` `init` ``,
    /// and `` `Type` `` and `` `Protocol` ``, which make a metatype after a
    /// type (`Fauna.Animal.Type`); the wildcard, `` `_` ``; and a name outside
    /// Swift's identifier grammar, which is then a raw identifier (SE-0451),
    /// `` `resource 3` ``.
    public static func swiftIdentifier(_ name: String) -> TokenSyntax {
        let bare = name.isValidSwiftIdentifier(for: .variableName)
            && name.isValidSwiftIdentifier(for: .memberAccess)
            && name.isValidMemberTypeName
        return .identifier(bare ? name : "`" + name + "`")
    }
}

extension String {
    /// Whether SwiftParser reads `T.name` as the member type `name` of `T`.
    /// `isValidSwiftIdentifier(for:)` checks a declaration and an expression
    /// only; in a type, `T.Type` and `T.Protocol` are metatypes.
    fileprivate var isValidMemberTypeName: Bool {
        var parser = Parser("T." + self)
        let type = TypeSyntax.parse(from: &parser)
        guard !type.hasError, let member = type.as(MemberTypeSyntax.self), member.genericArgumentClause == nil else { return false }
        return member.name.tokenKind == .identifier(self)
    }
}
