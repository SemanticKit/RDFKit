import SwiftSyntax
import SwiftSyntaxBuilder
import XSDDefinitions

/// Generates the Swift type of an XML Schema datatype (D6). A datatype whose
/// value space is exactly a Swift type is that type, which is made a literal;
/// any other is a struct in `XSD`, conforming to `RDFS.Literal`, whose value
/// is the Swift type of its primitive's value space.
///
///     extension XSD {
///         /// xsd:string (http://www.w3.org/TR/xmlschema11-2/#string)
///         public typealias string = String
///         /// xsd:decimal (http://www.w3.org/TR/xmlschema11-2/#decimal)
///         public struct decimal: RDFS.Literal, Hashable, Sendable {
///             public var value: DecimalNumber
///             public init(_ value: DecimalNumber)
///         }
///     }
///     extension String: RDFS.Literal {}
struct DatatypeEmitter {
    let definitions: DatatypeDefinitions

    /// The Swift type of the value space of each datatype translated so far.
    /// A datatype takes the value space of the nearest datatype it is
    /// derived from that has one.
    static let valueSpaces: [String: String] = [
        "string": "String",
        "boolean": "Bool",
        "double": "Double",
        "float": "Float",
        "decimal": "DecimalNumber",
        "integer": "BigInteger",
        "hexBinary": "[UInt8]",
        "base64Binary": "[UInt8]",
        "duration": "DurationValue",
    ].merging(TemporalEmitter.valueSpaces) { declared, _ in declared }

    /// The datatypes whose value space is exactly a Swift type: the datatype
    /// is that type (rule 20), which is a literal.
    static let swiftTypes: Set<String> = [
        "string",
        "boolean",
        "double",
        "float",
    ]

    func emit(_ names: [String]) throws -> String {
        let declarations = try names.map { try datatype(named: $0) }
        let lexical = LexicalEmitter(definitions: definitions)
        let literals = try names.filter(Self.swiftTypes.contains).compactMap { name in
            try Self.valueSpaces[name].map { ($0, try lexical.initializer(for: name, isSwiftType: true)) }
        }
        let file = SourceFileSyntax {
            ImportDeclSyntax(path: [ImportPathComponentSyntax(name: .identifier("Foundation"))])
            ImportDeclSyntax(path: [ImportPathComponentSyntax(name: .identifier("RDFKit"))])
            ExtensionDeclSyntax(
                extendedType: TypeSyntax("XSD"),
                memberBlock: MemberBlockSyntax {
                    for declaration in declarations { declaration }
                }
            )
            for (type, lexicalForm) in literals {
                ExtensionDeclSyntax(
                    leadingTrivia: doc(["A \(type) is a literal: the value space of an XML Schema datatype (RDF 1.2 Concepts §5.1)."]),
                    extendedType: TypeSyntax(stringLiteral: type),
                    inheritanceClause: InheritanceClauseSyntax {
                        InheritedTypeSyntax(type: TypeSyntax("RDFS.Literal"))
                    },
                    memberBlock: MemberBlockSyntax { lexicalForm }
                )
            }
            for binary in BinaryEmitter(definitions: definitions).extensions(for: names) { binary }
        }
        return file.formatted().description + "\n"
    }

    /// `public typealias string = String`, for a datatype whose value space is
    /// exactly a Swift type.
    private func typeAlias(_ name: String, for type: String, source: String?) -> DeclSyntax {
        DeclSyntax(TypeAliasDeclSyntax(
            leadingTrivia: doc(["xsd:\(name)" + (source.map { " (\($0))" } ?? "")]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            name: .identifier(name),
            initializer: TypeInitializerClauseSyntax(value: TypeSyntax(stringLiteral: type))
        ))
    }

    private func datatype(named name: String) throws -> DeclSyntax {
        if Self.swiftTypes.contains(name), let type = Self.valueSpaces[name] {
            return typeAlias(name, for: type, source: definitions.datatype(named: name)?.source)
        }
        if let duration = try DurationEmitter(definitions: definitions).datatype(named: name) {
            return duration
        }
        return DeclSyntax(try valueType(named: name))
    }

    private func valueType(named name: String) throws -> StructDeclSyntax {
        guard let definition = definitions.datatype(named: name) else {
            throw EmitError(description: "RDF 1.2 Concepts lists no xsd:\(name)")
        }
        guard let primitive = definitions.chain(to: definition).reversed().first(where: { Self.valueSpaces[$0.name] != nil }),
              let value = Self.valueSpaces[primitive.name] else {
            throw EmitError(description: "xsd:\(name) has no value space translated yet")
        }
        let valueType = TypeSyntax(stringLiteral: value)
        // The facets of the date and time datatypes are TemporalEmitter's.
        let checks = TemporalEmitter.valueSpaces[primitive.name] == nil
            ? try FacetEmitter(definitions: definitions).checks(for: definition, valueSpace: primitive, valueType: value)
            : FacetEmitter.Checks()
        // The lexical mapping, where LexicalEmitter has the primitive's; the
        // other primitives' emitters give their own.
        let lexicalForm = LexicalEmitter.lexicalMaps[definitions.chain(to: definition)[0].name] == nil
            ? nil
            : try LexicalEmitter(definitions: definitions).initializer(for: name, isSwiftType: false, valueThrows: !checks.statements.isEmpty)
        return StructDeclSyntax(
            leadingTrivia: doc(["xsd:\(name)" + (definition.source.map { " (\($0))" } ?? "")]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            name: .identifier(name),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax("RDFS.Literal"))
                InheritedTypeSyntax(type: TypeSyntax("Hashable"))
                InheritedTypeSyntax(type: TypeSyntax("Sendable"))
            },
            memberBlock: MemberBlockSyntax {
                VariableDeclSyntax(
                    leadingTrivia: doc(["The value, in the value space of xsd:\(primitive.name)."]),
                    modifiers: checks.statements.isEmpty ? [DeclModifierSyntax(name: .keyword(.public))] : [
                        DeclModifierSyntax(name: .keyword(.public)),
                        DeclModifierSyntax(name: .keyword(.private), detail: DeclModifierDetailSyntax(detail: .identifier("set"))),
                    ],
                    bindingSpecifier: .keyword(.var),
                    bindings: [PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
                        typeAnnotation: TypeAnnotationSyntax(type: valueType)
                    )]
                )
                InitializerDeclSyntax(
                    leadingTrivia: doc(["A value of xsd:\(name)."] + (checks.documentation.isEmpty ? [] : [
                        "",
                        "- Throws: `DatatypeError.illTyped` when the value is not in the value space of xsd:\(name): " + checks.documentation.joined(separator: ", ") + ".",
                    ])),
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    signature: FunctionSignatureSyntax(
                        parameterClause: FunctionParameterClauseSyntax {
                            FunctionParameterSyntax(firstName: .wildcardToken(), secondName: .identifier("value"), type: valueType)
                        },
                        effectSpecifiers: checks.statements.isEmpty ? nil : FacetEmitter.throwsClause
                    ),
                    body: CodeBlockSyntax {
                        for check in checks.statements { check }
                        InfixOperatorExprSyntax(
                            leftOperand: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .keyword(.self)), name: .identifier("value")),
                            operator: AssignmentExprSyntax(),
                            rightOperand: DeclReferenceExprSyntax(baseName: .identifier("value"))
                        )
                    }
                )
                for member in TemporalEmitter(definitions: definitions).members(of: definition, primitive: primitive) { member }
                if let lexicalForm { lexicalForm }
            }
        )
    }

    private func doc(_ lines: [String]) -> Trivia {
        Trivia(pieces: lines.flatMap { [TriviaPiece.docLineComment($0.isEmpty ? "///" : "/// \($0)"), .newlines(1)] })
    }
}
