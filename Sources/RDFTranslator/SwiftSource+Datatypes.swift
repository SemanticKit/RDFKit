import IRIKit
import RDFCore
import SwiftSyntax
import SwiftSyntaxBuilder
import TranslatorSyntax
import XSD

// The Swift of the properties whose range is an XSD datatype, built as
// swift-syntax nodes (DESIGN-CONTRACT rule 16).

extension ClassDeclaration {
    /// The value type of an XSD datatype, as Swift refers to it from any
    /// module: `XSD::nonNegativeInteger`.
    var datatypeType: TypeSyntax {
        .named(.escaped(name), in: module)
    }

    /// The Swift value type of the datatype, which reads its literals while
    /// the translator translates: the one of the `XSD` module's
    /// ``XSD/datatypes`` the datatype's declaration names.
    var datatypeValueType: (any SimpleType.Type)? {
        guard isDatatype else { return nil }
        return XSD.datatypes.first { $0.datatype.name == name }
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

    /// `resource.storage.state([try! XSD::nonNegativeInteger(lexicalForm: "212")], for: pagesValue.self)`:
    /// what the documents give `node` for `property`, as a decoder keeps it.
    /// Each literal is read with the range's Swift type here, while
    /// translating: one that denotes a value of the range is that value,
    /// and only the others, which stay literals, are kept as
    /// `RDFCore::Literal`s (`keeping:`).
    func statement(stating objects: [ObjectTerm], of node: SubjectTerm, for property: PropertyDeclaration) -> String {
        var range: ClassDeclaration?
        if case .datatype(let datatype) = property.kind { range = classDeclaration(datatype) }
        var values: [ExprSyntax] = []
        var literals: [ExprSyntax] = []
        for object in objects {
            guard case .literal(let literal) = object else { continue }
            if let range, let value = Self.valueExpression(literal, in: range) {
                values.append(value)
            } else {
                literals.append(Self.literalExpression(literal))
            }
        }
        var arguments: [(label: String?, value: ExprSyntax)] = [(nil, .array(values))]
        if !literals.isEmpty { arguments.append(("keeping", .array(literals))) }
        arguments.append(("for", .member(.keyword(.self), of: property.valueTypeExpression)))
        let storage = ExprSyntax.member(.identifier("storage"), of: .reference(.identifier(handle(node))))
        return ExprSyntax.call(.member(.identifier("state"), of: storage), arguments).formatted().description
    }

    /// The value `literal` denotes in `range`, as the expression that makes
    /// it, or `nil` when it denotes none and stays a literal: one with a
    /// language tag, an ill-typed one, one of a datatype with no Swift type
    /// and one whose value is outside the range (RDF 1.2 Concepts §5.1,
    /// XML Schema 1.1 Part 2 §2.1). The range's own initializer decides, the
    /// one a decoder reads the literal with.
    ///
    /// The value keeps the literal's lexical form and datatype, so the
    /// individual writes back the literal the documents give: a literal in
    /// the range's canonical form is `XSD::nonNegativeInteger(lexicalForm: "212")`,
    /// and any other, `"02"^^xsd:integer`, is
    /// `XSD::nonNegativeInteger(lexicalForm: "02", writtenAs: XSD::integer.self)`.
    /// The datatype is named by its Swift type; no IRI is written.
    static func valueExpression(_ literal: Literal, in range: ClassDeclaration) -> ExprSyntax? {
        guard literal.languageTag == nil, let type = range.datatypeValueType, let value = type.init(literal) else { return nil }
        let form = value.literalForm
        var arguments: [(label: String?, value: ExprSyntax)] = [("lexicalForm", .string(form.lexicalForm))]
        let isCanonical = form.datatype == type.datatype
            && form.lexicalForm.unicodeScalars.elementsEqual(value.lexicalForm.unicodeScalars)
        if !isCanonical {
            let written = ExprSyntax.reference(.escaped(form.datatype.name), in: range.module)
            arguments.append(("writtenAs", .member(.keyword(.self), of: written)))
        }
        // The literal was read with the same initializer, so it cannot throw.
        let call = ExprSyntax.call(.reference(.escaped(range.name), in: range.module), arguments)
        return ExprSyntax(TryExprSyntax(questionOrExclamationMark: .exclamationMarkToken(), expression: call))
    }

    /// A literal of the documents that stays a literal, as the boundary
    /// node: `RDFCore::Literal` with its lexical form, language tag, base
    /// direction and datatype IRI.
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
