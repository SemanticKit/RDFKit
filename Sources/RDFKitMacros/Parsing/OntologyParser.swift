import OntologyGeneration
import SwiftSyntax

/// Reads an ontology's `body`: its namespace and its declarations.
struct OntologyParser {
    static func parse(declaration: some DeclGroupSyntax) throws -> ParsedOntology {
        guard let statements = bodyStatements(of: declaration) else {
            throw MacroError("@Ontology requires a 'var body: some Content' computed property")
        }

        var namespace: String?
        var classes: [ParsedEntity] = []
        var properties: [ParsedEntity] = []
        for statement in statements {
            guard let call = statement.item.as(FunctionCallExprSyntax.self),
                  let form = formName(of: call),
                  let name = call.arguments.first.flatMap({ stringValue(of: $0.expression) }) else { continue }
            switch form {
            case "Namespace":
                namespace = name
            case "Class", "Datatype":
                classes.append(ParsedEntity(name: name, kind: form, annotations: try AnnotationParser.parse(from: call)))
            case "Property":
                properties.append(ParsedEntity(name: name, kind: form, annotations: try AnnotationParser.parse(from: call)))
            default:
                continue
            }
        }

        guard let namespace else {
            throw MacroError("The body must include a Namespace(\"...\") declaration")
        }
        let typeName = declaration.as(StructDeclSyntax.self)?.name.text ?? ""
        var ontology = ParsedOntology(name: typeName, namespace: namespace, classes: classes, properties: properties)
        ontology.schema = schema(of: ontology)
        return ontology
    }

    /// What the published semantics entail about the terms the body
    /// declares and names. A term of the ontology is its namespace and
    /// name; a term of another vocabulary, `RDFS.Class`, is named by the
    /// prefix the specifications give its namespace, `rdfs:`.
    static func schema(of ontology: ParsedOntology) -> SwiftSchema {
        let predicates = Schema([])
        let prefixes = publishedSemantics.prefixes
        func iri(_ swiftName: String) -> String? {
            guard let dot = swiftName.firstIndex(of: ".") else { return nil }
            let namespace = String(swiftName[..<dot])
            let local = swiftName[swiftName.index(after: dot)...]
            if namespace == ontology.name { return ontology.namespace + local }
            return prefixes.first { $0.prefix.uppercased() == namespace }.map { $0.namespace + local }
        }
        func swiftName(_ iri: String) -> String? {
            if iri.hasPrefix(ontology.namespace) { return "\(ontology.name).\(iri.dropFirst(ontology.namespace.count))" }
            return prefixes.first { iri.hasPrefix($0.namespace) }.map { "\($0.prefix.uppercased()).\(iri.dropFirst($0.namespace.count))" }
        }
        var triples: [Schema.Triple] = []
        let forms = [("Type", predicates.type), ("SubClassOf", predicates.subClassOf), ("Domain", predicates.domain), ("Range", predicates.range)]
        for entity in ontology.classes + ontology.properties {
            let subject = ontology.namespace + entity.name
            for (form, predicate) in forms {
                for annotation in entity.annotations where annotation.name == form {
                    if let object = iri(annotation.value) { triples.append(Schema.Triple(subject, predicate, object)) }
                }
            }
        }
        let schema = Schema(triples)
        let terms = Set(schema.triples.flatMap { [$0.subject, $0.object] })
        return SwiftSchema(schema, terms: Array(terms), swiftName: swiftName)
    }

    /// The name of the DSL form a call makes, `Class` in both `Class("Person")`
    /// and `RDFCore.Class("Class")`. RDF, RDFS and OWL qualify a form whose
    /// name a term they declare shadows.
    static func formName(of call: FunctionCallExprSyntax) -> String? {
        if let reference = call.calledExpression.as(DeclReferenceExprSyntax.self) {
            return reference.baseName.text
        }
        return call.calledExpression.as(MemberAccessExprSyntax.self)?.declName.baseName.text
    }

    /// The text of a string literal with no interpolation.
    static func stringValue(of expression: ExprSyntax) -> String? {
        guard let literal = expression.as(StringLiteralExprSyntax.self) else { return nil }
        var value = ""
        for segment in literal.segments {
            guard let text = segment.as(StringSegmentSyntax.self) else { return nil }
            value += text.content.text
        }
        return value
    }

    /// Whether a member is the ontology's `var body`.
    static func isBody(_ variable: VariableDeclSyntax) -> Bool {
        variable.bindings.contains { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "body" }
    }

    private static func bodyStatements(of declaration: some DeclGroupSyntax) -> CodeBlockItemListSyntax? {
        for member in declaration.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self), isBody(variable) else { continue }
            for binding in variable.bindings {
                switch binding.accessorBlock?.accessors {
                case .getter(let statements):
                    return statements
                case .accessors(let accessors):
                    if let statements = accessors.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.get) })?.body?.statements {
                        return statements
                    }
                default:
                    continue
                }
            }
        }
        return nil
    }
}
