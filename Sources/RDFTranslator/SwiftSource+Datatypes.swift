import IRIKit
import RDFCore
import SwiftSyntax
import SwiftSyntaxBuilder
import TranslatorSyntax

// The Swift of the properties whose range is an XSD datatype, built as
// swift-syntax nodes (DESIGN-CONTRACT rule 16).

extension ClassDeclaration {
    /// The value type of an XSD datatype, as Swift refers to it from any
    /// module: `XSD::nonNegativeInteger`.
    var datatypeType: TypeSyntax {
        .named(.escaped(name), in: module)
    }
}

extension PropertyDeclaration {
    /// The property's value type, as Swift refers to it from any module.
    var valueType: TypeSyntax {
        .named(.escaped(valueName), in: isPublic ? module : nil)
    }

    /// The property's value type as an expression, for `.self`.
    var valueTypeExpression: ExprSyntax {
        .reference(.escaped(valueName), in: isPublic ? module : nil)
    }
}

extension SwiftSource {
    /// `extension Library::pagesValue: RDFCore::DatatypePropertyValue {}`:
    /// the value type of a property whose range is an XSD datatype holds the
    /// datatype's values, so the literals the documents give it are stated
    /// through it.
    func datatypeConformance(of property: PropertyDeclaration) -> String {
        ExtensionDeclSyntax(
            extendedType: property.valueType,
            inheritanceClause: .of(.named(.identifier("DatatypePropertyValue"), in: "RDFCore")),
            memberBlock: MemberBlockSyntax(members: [])
        ).formatted().description
    }

    /// `resource.storage.state([literal, ...], for: pagesValue.self)`: the
    /// literals the documents give `node` for `property`, stated as a
    /// decoder states them.
    func statement(stating objects: [ObjectTerm], of node: SubjectTerm, for property: PropertyDeclaration) -> String {
        let literals = objects.compactMap { object -> Literal? in
            if case .literal(let literal) = object { return literal }
            return nil
        }
        let storage = ExprSyntax.member(.identifier("storage"), of: .reference(.identifier(handle(node))))
        return ExprSyntax.call(.member(.identifier("state"), of: storage), [
            (nil, .array(literals.map(Self.literalExpression))),
            ("for", .member(.keyword(.self), of: property.valueTypeExpression)),
        ]).formatted().description
    }

    /// A literal of the documents, as the boundary node: `RDFCore::Literal`
    /// with its lexical form, language tag, base direction and datatype IRI.
    static func literalExpression(_ literal: Literal) -> ExprSyntax {
        var arguments: [(label: String?, value: ExprSyntax)] = [(nil, .string(literal.lexicalForm))]
        if let language = literal.languageTag { arguments.append(("languageTag", .string(language))) }
        if let direction = literal.baseDirection { arguments.append(("baseDirection", .member(.identifier(direction.rawValue), of: nil))) }
        if let datatype = literal.datatype { arguments.append(("datatype", .string(datatype.rawValue))) }
        let call = ExprSyntax.call(.reference(.identifier("Literal"), in: "RDFCore"), arguments)
        // Only a language tag can be refused; a typed literal cannot.
        guard literal.languageTag != nil else { return call }
        return ExprSyntax(TryExprSyntax(questionOrExclamationMark: .exclamationMarkToken(), expression: call))
    }
}
