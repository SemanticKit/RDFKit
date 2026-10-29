import Foundation
import SwiftSyntax

/// Generates one Swift type per declared term.
///
/// - A `Class` or `Datatype` becomes a struct whose stored properties are the
///   ontology's properties with that type (or a superclass) as `Domain`, each
///   typed by its `Range`.
/// - A `Property` becomes a term type that names its `Domain` and `Range` as
///   type aliases.
/// - A term that RDFCore already provides as a DSL form becomes an alias of
///   that form.
/// - A term named like a declaration form (`OWL.Class`) becomes a declaration
///   form itself, because it shadows the RDFCore form inside its ontology.
///
/// Each generated type's IRI is computed here from the namespace and emitted
/// as a literal in its static metadata, for the boundary only. Generated code
/// never builds an identity at runtime.
struct EntityGenerator {
    enum Shape: Equatable {
        case alias(form: String, isGeneric: Bool)
        case declarationForm
        case value
        case propertyTerm
        case none
    }

    static func shape(of declaration: ParsedEntity, in ontology: ParsedOntology) -> Shape {
        if let form = BootstrapTerm.form(namespace: ontology.namespace, name: declaration.name) {
            return .alias(form: form.type, isGeneric: form.isGeneric)
        }
        switch declaration.kind {
        case .individual:
            return .none
        case .property:
            return .propertyTerm
        case .class, .datatype:
            return BootstrapTerm.declarationForms.contains(declaration.name) ? .declarationForm : .value
        }
    }

    static func generate(ontology: ParsedOntology) -> [DeclSyntax] {
        let planner = StoredPropertyPlanner(ontology: ontology)
        var generated: Set<String> = []
        return ontology.declarations.compactMap { declaration in
            // A term declared twice gets one type.
            guard generated.insert(declaration.name).inserted else { return nil }
            let source: String?
            switch shape(of: declaration, in: ontology) {
            case .alias(let form, let isGeneric):
                source = alias(declaration, form: form, isGeneric: isGeneric)
            case .declarationForm:
                source = declarationForm(declaration, in: ontology)
            case .value:
                source = valueType(declaration, in: ontology, planner: planner)
            case .propertyTerm:
                source = propertyTerm(declaration, in: ontology)
            case .none:
                source = nil
            }
            return source.map { DeclSyntax(stringLiteral: $0) }
        }
    }

    // MARK: - Shapes

    private static func alias(_ declaration: ParsedEntity, form: String, isGeneric: Bool) -> String {
        let name = SwiftIdentifier.escaped(declaration.name)
        let documentation = Documentation.docComment(for: declaration)
        if isGeneric {
            return "\(documentation)public typealias \(name)<Term: RDFCore.Entity> = RDFCore.`\(form)`<Term>"
        }
        return "\(documentation)public typealias \(name) = RDFCore.`\(form)`"
    }

    private static func declarationForm(_ declaration: ParsedEntity, in ontology: ParsedOntology) -> String {
        """
        \(Documentation.docComment(for: declaration))public struct \(SwiftIdentifier.escaped(declaration.name)): RDFCore.Declaration {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))

            public let localName: String
            public let content: RDFCore.Content

            public init(_ localName: String, @RDFCore.ContentBuilder _ content: () -> RDFCore.Content) {
                self.localName = localName
                self.content = content()
            }
        }
        """
    }

    private static func valueType(_ declaration: ParsedEntity, in ontology: ParsedOntology, planner: StoredPropertyPlanner) -> String {
        let properties = planner.storedProperties(of: declaration.name)

        let storage = properties.map { property in
            let wrapper = property.isIndirect ? "@RDFCore.Indirect " : ""
            return Documentation.docComment(for: property.declaration, indent: "    ")
                + "    \(wrapper)public var \(SwiftIdentifier.escaped(property.name)): \(property.valueType)"
        }.joined(separator: "\n\n")

        let parameters = properties.map { property in
            let name = SwiftIdentifier.escaped(property.name)
            let label = SwiftIdentifier.argumentLabel(for: property.name)
            return (label == name ? name : "\(label) \(name)") + ": \(property.valueType)"
        }.joined(separator: ", ")

        let assignments = properties.map { property in
            let name = SwiftIdentifier.escaped(property.name)
            return "        self.\(name) = \(name)"
        }.joined(separator: "\n")

        return """
        \(Documentation.docComment(for: declaration))public struct \(SwiftIdentifier.escaped(declaration.name)): RDFCore.Entity {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))
        \(storage.isEmpty ? "" : "\n" + storage + "\n")
            public init(\(parameters)) {\(assignments.isEmpty ? "}" : "\n" + assignments + "\n    }")
        }
        """
    }

    private static func propertyTerm(_ declaration: ParsedEntity, in ontology: ParsedOntology) -> String {
        var relations: [String] = []
        if let domain = declaration.term("Domain") {
            relations.append("    /// The type this property applies to.\n    public typealias Domain = \(ontology.spelling(of: ontology.resolve(domain)))")
        }
        if let range = declaration.term("Range") {
            relations.append("    /// The type of this property's values.\n    public typealias Range = \(ontology.spelling(of: ontology.resolve(range)))")
        }
        return """
        \(Documentation.docComment(for: declaration))public struct \(SwiftIdentifier.escaped(declaration.name)): RDFCore.Entity {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))
        \(relations.isEmpty ? "" : "\n" + relations.joined(separator: "\n\n"))
        }
        """
    }
}
