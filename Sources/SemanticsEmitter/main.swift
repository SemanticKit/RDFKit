import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

/// Translates the semantic tables of the W3C specifications to the
/// `Semantics` OntologyGeneration derives a vocabulary's schema from.
/// `SemanticsEmitterPlugin` runs it on every build of OntologyGeneration.
///
///     SemanticsEmitter <output.swift> <rdf12-semantics.html> <owl2-profiles.html> <owl2-rdf-based-semantics.html> <rdf12-schema.html>
do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    guard arguments.count == 5 else {
        throw EmitError(description: "usage: SemanticsEmitter <output.swift> <rdf12-semantics.html> <owl2-profiles.html> <owl2-rdf-based-semantics.html> <rdf12-schema.html>")
    }
    func tables(_ path: String) throws -> HTMLTables {
        HTMLTables(try String(contentsOf: URL(filePath: path), encoding: .utf8))
    }
    let reader = SemanticsReader(
        rdfSemantics: try tables(arguments[1]),
        owlProfiles: try tables(arguments[2]),
        owlRDFBasedSemantics: try tables(arguments[3]),
        rdfSchema: try tables(arguments[4])
    )
    try SemanticsSource(reader: reader).source().write(to: URL(filePath: arguments[0]), atomically: true, encoding: .utf8)
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(1)
}

struct EmitError: Error, CustomStringConvertible {
    let description: String
}

/// The rules, conditions and prefixes the tables state.
struct SemanticsReader {
    let rdfSemantics: HTMLTables
    let owlProfiles: HTMLTables
    let owlRDFBasedSemantics: HTMLTables
    let rdfSchema: HTMLTables

    struct Rule {
        let name: String
        let premises: [[String]]
        let conclusions: [[String]]
        let isInconsistency: Bool
    }

    /// The prefixes of OWL 2 RDF-Based Semantics Table 3.1 and of the
    /// namespace table of RDF 1.2 Schema.
    var prefixes: [(prefix: String, namespace: String)] {
        var found: [(String, String)] = []
        for row in owlRDFBasedSemantics.tables.flatMap(\.rows) + rdfSchema.tables.flatMap(\.rows) {
            guard let namespace = row.last, namespace.hasPrefix("http"), row.count >= 2 else { continue }
            let prefix = row[row.count - 2]
            guard prefix.wholeMatch(of: /[a-z]+/) != nil, !found.contains(where: { $0.0 == prefix }) else { continue }
            found.append((prefix, namespace))
        }
        return found
    }

    /// A pattern term's IRI, from a prefixed name, or its variable: `xxx` in
    /// RDF 1.2 Semantics, `?x` in OWL 2 Profiles.
    func term(_ token: String) -> (kind: String, value: String)? {
        if token.hasPrefix("?") || token.wholeMatch(of: /[a-z]{3}/) != nil { return ("variable", token) }
        guard let colon = token.firstIndex(of: ":") else { return nil }
        let prefix = String(token[..<colon])
        guard let namespace = prefixes.first(where: { $0.prefix == prefix })?.namespace else { return nil }
        return ("iri", namespace + token[token.index(after: colon)...])
    }

    /// The RDFS entailment patterns of RDF 1.2 Semantics, whose premises and
    /// conclusions are triple patterns.
    var rdfsEntailment: [Rule] {
        guard let table = rdfSemantics.tables.first(where: { $0.id == "rdfs_entailment_patterns" }) else { return [] }
        return table.rows.compactMap { row in
            guard row.count == 3, let premises = statements(row[1]), let conclusions = statements(row[2]) else { return nil }
            return Rule(name: row[0], premises: premises, conclusions: conclusions, isInconsistency: false)
        }
    }

    /// `aaa rdfs:domain xxx . yyy aaa zzz .` as its triple patterns, or nil
    /// when the text is not triple patterns only.
    func statements(_ text: String) -> [[String]]? {
        var statements: [[String]] = []
        var current: [String] = []
        for token in text.split(separator: " ").map(String.init) {
            if token == "." {
                guard current.count == 3 else { return nil }
                statements.append(current)
                current = []
            } else {
                current.append(token)
            }
        }
        guard current.isEmpty, !statements.isEmpty, statements.allSatisfy({ $0.allSatisfy { term($0) != nil } }) else { return nil }
        return statements
    }

    /// The OWL 2 RL rules of OWL 2 Profiles §4.3 whose premises and
    /// conclusions are `T(s, p, o)` patterns, or whose conclusion is
    /// `false`.
    var owl2RL: [Rule] {
        owlProfiles.tables.flatMap(\.rows).compactMap { row in
            guard row.count == 3, row[0].wholeMatch(of: /[a-z]+-[a-z0-9]+/) != nil,
                  let premises = patterns(row[1]), !premises.isEmpty else { return nil }
            if row[2] == "false" {
                return Rule(name: row[0], premises: premises, conclusions: [], isInconsistency: true)
            }
            guard let conclusions = patterns(row[2]), !conclusions.isEmpty else { return nil }
            return Rule(name: row[0], premises: premises, conclusions: conclusions, isInconsistency: false)
        }
    }

    /// `T(?p, rdf:type, owl:FunctionalProperty) T(?x, ?p, ?y 1 )` as its
    /// triple patterns, or nil when the text is not such patterns only.
    func patterns(_ text: String) -> [[String]]? {
        let pattern = /T\((?<arguments>[^)]*)\)/
        let rest = text.replacing(pattern, with: "").trimmingCharacters(in: .whitespaces)
        guard rest.isEmpty else { return nil }
        let found = text.matches(of: pattern).map { match in
            match.arguments.split(separator: ",").map { String($0.replacing(" ", with: "")) }
        }
        guard found.allSatisfy({ $0.count == 3 && $0.allSatisfy { term($0) != nil } }) else { return nil }
        return found
    }

    /// The conditions on the class extensions of the built-in classes (OWL
    /// 2 RDF-Based Semantics §5.2): `owl:Thing | ∈ IC | = IR`.
    var classExtensions: [(class: String, isEqual: Bool, part: String)] {
        owlRDFBasedSemantics.tables.flatMap(\.rows).compactMap { row in
            guard row.count == 3, row[1] == "∈ IC", let iri = term(row[0]), iri.kind == "iri",
                  let condition = row[2].wholeMatch(of: /(?<relation>=|⊆) (?<part>\S+)/) else { return nil }
            return (iri.value, condition.relation == "=", String(condition.part))
        }
    }

    /// The parts the built-in properties belong to (§5.3): `rdfs:label | ∈ IOAP`.
    var propertyExtensions: [(property: String, part: String)] {
        owlRDFBasedSemantics.tables.flatMap(\.rows).compactMap { row in
            guard row.count == 3, let iri = term(row[0]), iri.kind == "iri",
                  let membership = row[1].wholeMatch(of: /∈ (?<part>I[A-Z]+)/), membership.part != "IC" else { return nil }
            return (iri.value, String(membership.part))
        }
    }

    /// The parts of the universe (§4.1): their supersets, `IC | S ⊆ IR`, and
    /// the class whose extension each is, `classes | IC | rdfs:Class`.
    var parts: [(name: String, supersets: [String], class: String?)] {
        let rows = owlRDFBasedSemantics.tables.flatMap(\.rows)
        var names: [String] = []
        var supersets: [String: [String]] = [:]
        var classes: [String: String] = [:]
        for row in rows where row.count >= 2 {
            if row[0].wholeMatch(of: /I[A-Z]+|LV/) != nil, let subset = row[1].wholeMatch(of: /S (?:⊆ (?<superset>\S+)|≠ ∅)/) {
                if !names.contains(row[0]) { names.append(row[0]) }
                if let superset = subset.superset { supersets[row[0], default: []].append(String(superset)) }
            }
            if row.count == 3, row[1].wholeMatch(of: /I[A-Z]+|LV/) != nil, let iri = term(row[2]), iri.kind == "iri" {
                if !names.contains(row[1]) { names.append(row[1]) }
                classes[row[1]] = iri.value
            }
        }
        return names.map { ($0, supersets[$0] ?? [], classes[$0]) }
    }
}

/// The Swift of `publishedSemantics`, built with SwiftSyntaxBuilder.
struct SemanticsSource {
    let reader: SemanticsReader

    func source() throws -> String {
        let file = SourceFileSyntax {
            VariableDeclSyntax(
                leadingTrivia: Trivia(pieces: [
                    .docLineComment("/// The semantics of RDF 1.2 Semantics, OWL 2 Profiles and OWL 2 RDF-Based"), .newlines(1),
                    .docLineComment("/// Semantics, read from their tables (Sources/OntologyGeneration/W3C)."), .newlines(1),
                ]),
                modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                bindingSpecifier: .keyword(.let),
                bindings: [PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier("publishedSemantics")),
                    initializer: InitializerClauseSyntax(value: call("Semantics", [
                        ("rdfsEntailment", array(reader.rdfsEntailment.map(rule))),
                        ("owl2RL", array(reader.owl2RL.map(rule))),
                        ("classExtensions", array(reader.classExtensions.map { condition in
                            call("ClassExtension", [("class", string(condition.class)), ("isEqual", boolean(condition.isEqual)), ("part", string(condition.part))])
                        })),
                        ("propertyExtensions", array(reader.propertyExtensions.map { membership in
                            call("PropertyExtension", [("property", string(membership.property)), ("part", string(membership.part))])
                        })),
                        ("parts", array(reader.parts.map { part in
                            call("UniversePart", [
                                ("name", string(part.name)),
                                ("supersets", array(part.supersets.map(string))),
                                ("class", part.class.map(string) ?? ExprSyntax(NilLiteralExprSyntax())),
                            ])
                        })),
                        ("prefixes", array(reader.prefixes.map { call("NamespacePrefix", [(nil, string($0.prefix)), (nil, string($0.namespace))]) })),
                    ]))
                )]
            )
        }
        return file.formatted().description + "\n"
    }

    private func rule(_ rule: SemanticsReader.Rule) -> ExprSyntax {
        call("EntailmentRule", [
            ("name", string(rule.name)),
            ("premises", array(rule.premises.map(pattern))),
            ("conclusions", array(rule.conclusions.map(pattern))),
            ("isInconsistency", boolean(rule.isInconsistency)),
        ])
    }

    private func pattern(_ tokens: [String]) -> ExprSyntax {
        call("TriplePattern", tokens.map { token in (nil, term(token)) })
    }

    private func term(_ token: String) -> ExprSyntax {
        let term = reader.term(token)!
        return ExprSyntax(FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(name: .identifier(term.kind)),
            leftParen: .leftParenToken(),
            arguments: [LabeledExprSyntax(expression: string(term.value))],
            rightParen: .rightParenToken()
        ))
    }

    private func call(_ name: String, _ arguments: [(label: String?, value: ExprSyntax)]) -> ExprSyntax {
        ExprSyntax(FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(baseName: .identifier(name)),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                for argument in arguments { LabeledExprSyntax(label: argument.label, expression: argument.value) }
            },
            rightParen: .rightParenToken()
        ))
    }

    private func array(_ elements: [ExprSyntax]) -> ExprSyntax {
        ExprSyntax(ArrayExprSyntax { for element in elements { ArrayElementSyntax(expression: element) } })
    }

    private func string(_ value: String) -> ExprSyntax {
        ExprSyntax(StringLiteralExprSyntax(content: value))
    }

    private func boolean(_ value: Bool) -> ExprSyntax {
        ExprSyntax(BooleanLiteralExprSyntax(value))
    }
}
