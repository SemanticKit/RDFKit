import SwiftSyntax
import SwiftSyntaxBuilder
import XSDDefinitions

/// Generates the checks the initializer of a derived datatype makes: each
/// constraining facet (XML Schema 1.1 Part 2 §4.3) that the definitions
/// below the datatype whose value space it takes give, as `derived.nxsd`
/// gives them, is a `guard` that throws `DatatypeError.illTyped` for a value
/// outside the datatype's value space.
///
///     /// xsd:byte (http://www.w3.org/TR/xmlschema11-2/#byte)
///     public struct byte: RDFS.Literal, Hashable, Sendable {
///         public private(set) var value: BigInteger
///         public init(_ value: BigInteger) throws(DatatypeError) {
///             guard value >= BigInteger(-128) else {
///                 throw DatatypeError.illTyped
///             }
///             guard value <= BigInteger(127) else {
///                 throw DatatypeError.illTyped
///             }
///             self.value = value
///         }
///     }
///
/// The facets of the datatype whose value space is taken, and of the ones
/// it is derived from, hold of every value of the Swift type already
/// (xsd:integer's `fractionDigits` 0 of a `BigInteger`). Of the facets below
/// it, a step that restates a facet narrows and replaces it (§4.3), so each
/// is checked as the last step gives it; patterns are not replaced but
/// added, a value matching a pattern of each step, and a step's several
/// patterns are alternatives (§4.3.4).
///
/// The value-based facets, the bounds (§4.3.7 to §4.3.10) and the lengths
/// (§4.3.1 to §4.3.3), constrain the value. The lexical facets, `pattern`
/// (§4.3.4) and `whiteSpace` (§4.3.6), constrain the lexical form, which is
/// the value itself only in a value space of strings (§3.3.1: the lexical
/// mapping of xsd:string maps a string to itself), so they are checked
/// there alone.
struct FacetEmitter {
    let definitions: DatatypeDefinitions

    /// The checks of an initializer, and the lines that document them.
    struct Checks {
        var statements: [StmtSyntax] = []
        var documentation: [String] = []
    }

    /// The Swift types whose values are their own lexical forms.
    static let characterValueSpaces: Set<String> = ["String"]

    /// The facets that hold one value per datatype, in the order they are
    /// checked, and what each requires of the value.
    private static let singleFacets: [(name: String, kind: Kind)] = [
        ("whiteSpace", .whiteSpace),
        ("length", .length("==")),
        ("minLength", .length(">=")),
        ("maxLength", .length("<=")),
        ("minInclusive", .bound(">=")),
        ("minExclusive", .bound(">")),
        ("maxInclusive", .bound("<=")),
        ("maxExclusive", .bound("<")),
    ]

    private enum Kind {
        /// The value compared, by the operator, with the facet's value, a
        /// literal of the datatype restricted.
        case bound(String)
        /// The value's length in characters compared with a number.
        case length(String)
        case whiteSpace
    }

    /// The checks `definition` makes of a value in the value space of
    /// `valueSpace`, the datatype it is derived from whose Swift type is
    /// `valueType`.
    func checks(for definition: SimpleTypeDefinition, valueSpace: SimpleTypeDefinition, valueType: String) throws -> Checks {
        let chain = definitions.chain(to: definition)
        guard let index = chain.firstIndex(where: { $0.name == valueSpace.name }) else {
            throw EmitError(description: "xsd:\(definition.name) is not derived from xsd:\(valueSpace.name)")
        }
        var single: [String: (value: String, step: String)] = [:]
        var patterns: [(values: [String], step: String)] = []
        for step in chain[chain.index(after: index)...] {
            var alternatives: [String] = []
            for facet in step.facets {
                let declared = definitions.vocabulary.facets[facet.name]
                if facet.name == "pattern", declared == .alternatives {
                    alternatives.append(facet.value)
                } else if let kind = Self.singleFacets.first(where: { $0.name == facet.name })?.kind, Self.declares(declared, kind, facet.value) {
                    single[facet.name] = (facet.value, step.name)
                } else {
                    throw EmitError(description: "xsd:\(definition.name): xsd:\(step.name) gives the facet \(facet.name) \"\(facet.value)\", which has no translation")
                }
            }
            if !alternatives.isEmpty { patterns.append((alternatives, step.name)) }
        }
        var checks = Checks()
        for (name, kind) in Self.singleFacets {
            guard let given = single[name] else { continue }
            let (value, step) = given
            let condition: ExprSyntax?
            switch kind {
            case .bound(let operation):
                let bound = try literal(value, of: valueType, facet: name, in: step)
                condition = ExprSyntax(compare(valueExpr, operation, bound))
            case .length(let operation):
                guard Self.characterValueSpaces.contains(valueType), let count = Int(value) else {
                    throw EmitError(description: "xsd:\(step): \(name) \(value) has no translation for a \(valueType)")
                }
                let length = MemberAccessExprSyntax(
                    base: MemberAccessExprSyntax(base: valueExpr, name: .identifier("unicodeScalars")),
                    name: .identifier("count")
                )
                condition = ExprSyntax(compare(length, operation, IntegerLiteralExprSyntax(literal: .integerLiteral(String(count)))))
            case .whiteSpace:
                guard Self.characterValueSpaces.contains(valueType) else {
                    throw EmitError(description: "xsd:\(step): whiteSpace \(value) constrains the lexical form, which a \(valueType) is not")
                }
                condition = Self.whiteSpacePatterns[value].map { ExprSyntax(matches($0)) }
            }
            guard let condition else { continue }
            checks.statements.append(guardStatement(condition))
            checks.documentation.append("\(name) \(value) (xsd:\(step))")
        }
        for (values, step) in patterns {
            guard Self.characterValueSpaces.contains(valueType) else {
                throw EmitError(description: "xsd:\(step): pattern constrains the lexical form, which a \(valueType) is not")
            }
            let regex = try values.map { try PatternTranslation(xsd: $0).regex }
            let pattern = regex.count == 1 ? regex[0] : regex.map { "(?:\($0))" }.joined(separator: "|")
            // A translation the Swift regex syntax does not accept fails the
            // build here, not the initializer.
            do { _ = try Regex(pattern) } catch {
                throw EmitError(description: "xsd:\(step): the pattern \(values) translates to \(pattern), which is not a Swift regex: \(error)")
            }
            checks.statements.append(guardStatement(ExprSyntax(matches(pattern))))
            checks.documentation.append("pattern \(values.joined(separator: " or ")) (xsd:\(step))")
        }
        return checks
    }

    /// The `throws(DatatypeError)` of an initializer that checks.
    static var throwsClause: FunctionEffectSpecifiersSyntax {
        FunctionEffectSpecifiersSyntax(
            throwsClause: ThrowsClauseSyntax(
                throwsSpecifier: .keyword(.throws),
                leftParen: .leftParenToken(),
                type: IdentifierTypeSyntax(name: .identifier("DatatypeError")),
                rightParen: .rightParenToken()
            )
        )
    }

    /// The value spaces of the `whiteSpace` facet's values (§4.3.6.1): of
    /// `replace`, the strings with no tab (#x9), line feed (#xA) or carriage
    /// return (#xD); of `collapse`, those of them with no leading or
    /// trailing space (#x20) and no two spaces in a row (§3.4.1, §3.4.2).
    /// `preserve` constrains nothing.
    private static let whiteSpacePatterns: [String: String] = [
        "replace": #"[^\t\n\r]*"#,
        "collapse": #"(?:[^\t\n\r ]+(?: [^\t\n\r ]+)*)?"#,
    ]

    /// Whether the schema for schema documents declares a facet of `kind`,
    /// and, for a keyword, `value` among its keywords.
    private static func declares(_ declared: FacetVocabulary.Kind?, _ kind: Kind, _ value: String) -> Bool {
        switch (kind, declared) {
        case (.bound, .literal?), (.length, .number?): return true
        case (.whiteSpace, .keyword(let keywords)?): return keywords.contains(value)
        default: return false
        }
    }

    private var valueExpr: DeclReferenceExprSyntax {
        DeclReferenceExprSyntax(baseName: .identifier("value"))
    }

    /// `lhs <operation> rhs`.
    private func compare(_ lhs: some ExprSyntaxProtocol, _ operation: String, _ rhs: some ExprSyntaxProtocol) -> InfixOperatorExprSyntax {
        InfixOperatorExprSyntax(
            leftOperand: lhs,
            operator: BinaryOperatorExprSyntax(operator: .binaryOperator(operation)),
            rightOperand: rhs
        )
    }

    /// `guard <condition> else { throw DatatypeError.illTyped }`.
    private func guardStatement(_ condition: ExprSyntax) -> StmtSyntax {
        StmtSyntax(GuardStmtSyntax(
            conditions: ConditionElementListSyntax {
                ConditionElementSyntax(condition: .expression(condition))
            },
            body: CodeBlockSyntax {
                ThrowStmtSyntax(expression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: .identifier("DatatypeError")),
                    name: .identifier("illTyped")
                ))
            }
        ))
    }

    /// `value.wholeMatch(of: try! Regex(#"<pattern>"#).matchingSemantics(.unicodeScalar)) != nil`:
    /// a pattern matches the whole of a string, character by character
    /// a character being a code point, not a grapheme cluster.
    private func matches(_ pattern: String) -> InfixOperatorExprSyntax {
        let regex = FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(baseName: .identifier("Regex")),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(expression: StringLiteralExprSyntax(
                    openDelimiter: .rawStringPoundDelimiter("#"),
                    content: pattern,
                    closeDelimiter: .rawStringPoundDelimiter("#")
                ))
            },
            rightParen: .rightParenToken()
        )
        let semantics = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(base: regex, name: .identifier("matchingSemantics")),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(expression: MemberAccessExprSyntax(
                    period: .periodToken(),
                    declName: DeclReferenceExprSyntax(baseName: .identifier("unicodeScalar"))
                ))
            },
            rightParen: .rightParenToken()
        )
        let match = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(base: valueExpr, name: .identifier("wholeMatch")),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(
                    label: .identifier("of"),
                    colon: .colonToken(),
                    expression: TryExprSyntax(questionOrExclamationMark: .exclamationMarkToken(), expression: semantics)
                )
            },
            rightParen: .rightParenToken()
        )
        return compare(match, "!=", NilLiteralExprSyntax())
    }

    /// The Swift value of a facet's literal, a literal of the datatype
    /// restricted, in its value space's Swift type.
    private func literal(_ text: String, of valueType: String, facet: String, in step: String) throws -> ExprSyntax {
        guard valueType == "BigInteger" else {
            throw EmitError(description: "xsd:\(step): \(facet) \(text) has no translation for a \(valueType)")
        }
        // The lexical form of xsd:integer (§3.4.13.1): an optional sign and
        // digits.
        let isNegative = text.hasPrefix("-")
        let digits = text.hasPrefix("-") || text.hasPrefix("+") ? String(text.dropFirst()) : text
        guard !digits.isEmpty, digits.unicodeScalars.allSatisfy({ ("0"..."9").contains($0) }) else {
            throw EmitError(description: "xsd:\(step): \(facet) \(text) is not an xsd:integer")
        }
        let integer = DeclReferenceExprSyntax(baseName: .identifier("BigInteger"))
        if let magnitude = Int(digits) {
            // BigInteger(-128)
            let literal = IntegerLiteralExprSyntax(literal: .integerLiteral(String(magnitude)))
            let argument = isNegative && magnitude != 0
                ? ExprSyntax(PrefixOperatorExprSyntax(operator: .prefixOperator("-"), expression: literal))
                : ExprSyntax(literal)
            return ExprSyntax(FunctionCallExprSyntax(
                calledExpression: integer,
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax { LabeledExprSyntax(expression: argument) },
                rightParen: .rightParenToken()
            ))
        }
        // BigInteger(digits: "18446744073709551615")!, for a magnitude
        // beyond Int's.
        var arguments = [LabeledExprSyntax(label: .identifier("digits"), colon: .colonToken(), expression: StringLiteralExprSyntax(content: digits))]
        if isNegative {
            arguments[0].trailingComma = .commaToken()
            arguments.append(LabeledExprSyntax(label: .identifier("isNegative"), colon: .colonToken(), expression: BooleanLiteralExprSyntax(literal: .keyword(.true))))
        }
        return ExprSyntax(ForceUnwrapExprSyntax(expression: FunctionCallExprSyntax(
            calledExpression: integer,
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax(arguments),
            rightParen: .rightParenToken()
        )))
    }
}

/// An XML Schema regular expression (XML Schema 1.1 Part 2 Appendix G) in
/// the regex syntax of Swift (SE-0355), to match the whole of a string.
///
/// The two differ in: `.`, which in XML Schema matches any character but
/// line feed and carriage return; `^` and `$`, which are normal
/// characters outside a character class; character class
/// subtraction, `[a-[b]]`, which Swift writes `[[a]--[b]]`;
/// `&` and `~`, which Swift's character classes give meaning to; and the
/// multi-character escapes `\i` and `\c`, which XML Schema
/// defines as the characters XML's `NameStartChar` and `NameChar` match.
struct PatternTranslation {
    /// The Swift regex.
    let regex: String

    init(xsd pattern: String) throws {
        var scanner = Scanner(xsd: pattern, scalars: Array(pattern.unicodeScalars))
        var regex = ""
        while scanner.current != nil {
            regex += try scanner.atom()
        }
        self.regex = regex
    }

    /// XML 1.0 (Fifth Edition) §2.3, production [4] `NameStartChar`.
    static let nameStartChar: [ClosedRange<UInt32>] = [
        0x3A...0x3A, 0x41...0x5A, 0x5F...0x5F, 0x61...0x7A,
        0xC0...0xD6, 0xD8...0xF6, 0xF8...0x2FF, 0x370...0x37D,
        0x37F...0x1FFF, 0x200C...0x200D, 0x2070...0x218F, 0x2C00...0x2FEF,
        0x3001...0xD7FF, 0xF900...0xFDCF, 0xFDF0...0xFFFD, 0x10000...0xEFFFF,
    ]

    /// XML 1.0 (Fifth Edition) §2.3, production [4a] `NameChar`.
    static let nameChar: [ClosedRange<UInt32>] = nameStartChar + [
        0x2D...0x2E, 0x30...0x39, 0xB7...0xB7, 0x300...0x36F, 0x203F...0x2040,
    ]

    /// The members of a character class matching `ranges`.
    ///
    /// Swift's regex parser compares the bounds of a range as characters,
    /// and rejects a bound that is a canonical singleton, such as U+F900,
    /// which normalizes to U+8C48 ("invalid bound for character class
    /// range"). Such a range is the range from the scalar before it, less
    /// that scalar: `[\u{F8FF}-\u{FDCF}]--[\u{F8FF}]`.
    fileprivate static func members(_ ranges: [ClosedRange<UInt32>]) throws -> String {
        func scalar(_ value: UInt32) -> String { "\\u{" + String(value, radix: 16, uppercase: true) + "}" }
        return try ranges.map { range in
            guard range.count > 1 else { return scalar(range.lowerBound) }
            let members = scalar(range.lowerBound) + "-" + scalar(range.upperBound)
            if (try? Regex("[" + members + "]")) != nil { return members }
            let before = range.lowerBound - 1
            let widened = "[[" + scalar(before) + "-" + scalar(range.upperBound) + "]--[" + scalar(before) + "]]"
            guard (try? Regex("[" + widened + "]")) != nil else {
                throw EmitError(description: "the range \(members) is not a Swift regex character class")
            }
            return widened
        }.joined()
    }
}

/// A pattern read from its start, one atom at a time.
private struct Scanner {
    let xsd: String
    let scalars: [Unicode.Scalar]
    var index = 0

    var current: Unicode.Scalar? { index < scalars.count ? scalars[index] : nil }

    private func error(_ reason: String) -> EmitError {
        EmitError(description: "the pattern \(xsd): \(reason)")
    }

    /// The translation of what begins at `index`, outside a character class.
    mutating func atom() throws -> String {
        guard let scalar = current else { throw error("ends early") }
        switch scalar {
        case "[":
            return try characterClass()
        case "\\":
            return try escape(inClass: false)
        case ".":
            index += 1
            return #"[^\n\r]"#
        case "^", "$":
            index += 1
            return "\\" + String(scalar)
        default:
            index += 1
            return String(scalar)
        }
    }

    /// A character class, from its `[` to its `]`.
    private mutating func characterClass() throws -> String {
        index += 1
        var negated = false
        if current == "^" {
            negated = true
            index += 1
        }
        var members = ""
        while true {
            guard let scalar = current else { throw error("a character class has no ]") }
            switch scalar {
            case "]":
                index += 1
                guard !members.isEmpty else { throw error("a character class is empty") }
                return "[" + (negated ? "^" : "") + members + "]"
            case "-" where index + 1 < scalars.count && scalars[index + 1] == "[":
                index += 1
                let subtracted = try characterClass()
                guard current == "]" else { throw error("a subtraction does not end its character class") }
                index += 1
                return "[[" + (negated ? "^" : "") + members + "]--" + subtracted + "]"
            case "\\":
                members += try escape(inClass: true)
            case "[", "&", "~":
                index += 1
                members += "\\" + String(scalar)
            default:
                index += 1
                members += String(scalar)
            }
        }
    }

    /// An escape, from its `\`.
    private mutating func escape(inClass: Bool) throws -> String {
        index += 1
        guard let scalar = current else { throw error("ends in \\") }
        index += 1
        switch scalar {
        case "i", "c":
            let members = try PatternTranslation.members(scalar == "i" ? PatternTranslation.nameStartChar : PatternTranslation.nameChar)
            return inClass ? members : "[" + members + "]"
        case "I", "C":
            guard !inClass else { throw error("\\\(scalar) in a character class has no translation") }
            return "[^" + (try PatternTranslation.members(scalar == "I" ? PatternTranslation.nameStartChar : PatternTranslation.nameChar)) + "]"
        case "n", "r", "t", "\\", "|", ".", "?", "*", "+", "(", ")", "{", "}", "-", "[", "]", "^":
            return "\\" + String(scalar)
        default:
            throw error("the escape \\\(scalar) has no translation")
        }
    }
}
