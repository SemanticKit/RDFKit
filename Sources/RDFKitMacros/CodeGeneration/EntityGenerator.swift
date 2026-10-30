import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Generates the Swift declarations for an ontology's terms: the same Swift
/// `RDFTranslatorPlugin` writes for the RDF it translates, on the same
/// runtime (``RDFCore/Resource``, ``RDFCore/IndividualStorage``).
///
/// - A class becomes a protocol (`Fauna.Animal`) whose requirements are the
///   properties with the class as `Domain`, typed by their `Range`
///   (`[any Fauna.Habitat]`); `SubClassOf` becomes protocol refinement, and a
///   class with no superclass refines `RDF.Resource` (rdfs4). It also gets a
///   storing protocol (`Fauna.AnimalStoring`), which gives a member every
///   property it can have, and a final class whose instances are its
///   members (`Fauna.AnimalIndividual`), which RDFFormats' `GraphDecoder`
///   can make from a document (``RDFCore/DecodableResource``). The class writes its own
///   description: the `Type`, `SubClassOf`, `Label`, `Comment`, `SeeAlso`
///   and `Deprecated` it is declared with.
/// - A datatype is a class whose members are literals.
/// - A property becomes a term type, which writes its own description
///   (`Type`, `Domain`, `Range`, `Label`, `Comment`, `SeeAlso`,
///   `Deprecated`), and a value type and storing protocol that keep its
///   values in an individual's ``RDFCore/IndividualStorage``; the value
///   type encodes and decodes them, keyed by the property.
/// - The ontology type gets `ontology`, the descriptions of its terms, the
///   way back to RDF, as a translated module has.
/// - An `Individual` (`owl:NamedIndividual`) becomes a final class that
///   conforms to the storing protocol of each class its `Type` gives and
///   carries the individual's declared key, and an ontology member whose
///   value is the one instance of that class.
///
/// No generated type holds an IRI. Each carries its declared key, its
/// declared name in the ontology (the ``RDFCore/Vocabulary`` whose
/// `namespace` the `Namespace` declaration gives), and an encoder derives the
/// IRI from it at the boundary.
struct EntityGenerator {
    let model: OntologyModel
    let context: any MacroExpansionContext

    private var ontology: ParsedOntology { model.ontology }

    init(ontology: ParsedOntology, context: some MacroExpansionContext) {
        self.model = OntologyModel(ontology: ontology)
        self.context = context
    }

    /// The members of the ontology type: the Swift of its classes and
    /// properties.
    func members() -> [DeclSyntax] {
        diagnoseUndeclaredTerms()
        diagnoseRedeclarations()
        var descriptions: [String] = []
        // Every declaration of a term is merged into one by the parser, so
        // each term gets one set of types.
        let members = ontology.declarations.flatMap { declaration -> [DeclSyntax] in
            guard let shape = model.shape(of: declaration.name) else { return [] }
            let sources: [String]
            switch shape {
            case .class, .datatype:
                sources = classDeclarations(declaration)
                if sources.count > 1 {
                    descriptions.append("RDFCore.ClassDescription(\(ontology.typeName).\(ClassNames(className: SwiftIdentifier.sanitized(declaration.name)).individual).self)")
                }
            case .property:
                sources = propertyDeclarations(declaration)
                descriptions.append("\(ontology.typeName).\(SwiftIdentifier.escaped(declaration.name))()")
            case .individual:
                sources = individualDeclarations(declaration)
                if !sources.isEmpty { descriptions.append(SwiftIdentifier.escaped(declaration.name)) }
            }
            return sources.map { DeclSyntax(stringLiteral: $0) }
        }
        let namespace = DeclSyntax(stringLiteral: """
            /// The namespace this ontology's terms are declared in, from which an
            /// encoder derives each term's IRI.
            \(access)static let namespace = \(Documentation.literal(ontology.namespace))
            """)
        return members + [DeclSyntax(stringLiteral: ontologyDescriptions(descriptions)), namespace]
    }

    /// `ontology`: the description of every term the ontology declares, the
    /// way back to RDF, as a translated module's `ontology` is.
    private func ontologyDescriptions(_ descriptions: [String]) -> String {
        """
        /// The descriptions of the terms this ontology declares.
        ///
        /// Encoding them gives the ontology's graph:
        ///
        ///     let document = try TurtleEncoder().encode(\(ontology.typeName)().ontology)
        \(access)var ontology: [any RDFCore.Description] {
            [\(descriptions.map { "\n        \($0)," }.joined())\(descriptions.isEmpty ? "" : "\n    ")]
        }
        """
    }

    /// Reports, at the authored annotation, a related term written as a term
    /// of this ontology that the ontology does not declare: `Fauna.Habitatt`.
    private func diagnoseUndeclaredTerms() {
        for declaration in ontology.declarations {
            for annotation in declaration.annotations {
                guard let spelling = annotation.term,
                      let name = ontology.resolve(spelling).localName,
                      ontology.declaration(named: name) == nil else { continue }
                context.diagnose(Diagnostic(
                    node: annotation.syntax,
                    message: OntologyDiagnostic.undeclaredTerm(spelling, ontology: ontology.typeName)
                ))
            }
        }
    }

    /// Reports, at the later declaration, a term declared again with
    /// another form: `Property("name")` after `Class("name")`.
    private func diagnoseRedeclarations() {
        for redeclaration in ontology.redeclarations {
            let declaration = redeclaration.declaration
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.declaredWithAnotherForm(
                    declaration.name,
                    form: declaration.kind.rawValue,
                    firstForm: redeclaration.firstKind.rawValue
                )
            ))
        }
    }

    /// Reports a generated name that a declared term already has.
    private func collides(_ names: [String], with declaration: ParsedEntity) -> Bool {
        for taken in names where ontology.declaration(named: taken) != nil {
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.individualTypeCollides(name: taken, className: declaration.name)
            ))
            return true
        }
        return false
    }

    private var access: String { ontology.access }

    // MARK: - Classes

    private func classDeclarations(_ declaration: ParsedEntity) -> [String] {
        let name = SwiftIdentifier.escaped(declaration.name)
        let names = ClassNames(className: SwiftIdentifier.sanitized(declaration.name))
        let requirements = model.ownRequirements(of: declaration.name).map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    var \(requirement.name): \(requirement.declaredType) { get set }"
        }.joined(separator: "\n\n")
        let protocolSource = """
        \(Documentation.docComment(for: declaration))\(access)protocol \(name): \(model.refinements(of: declaration.name).joined(separator: ", ")) {\(requirements.isEmpty ? "}" : "\n" + requirements + "\n}")
        """
        guard !collides([names.storing, names.individual], with: declaration) else { return [protocolSource] }

        var storing = ["\(ontology.typeName).\(name)"]
        for requirement in model.ownRequirements(of: declaration.name) {
            let property = "\(ontology.typeName).\(ClassNames(className: SwiftIdentifier.sanitized(requirement.declaration.name)).storing)"
            if !storing.contains(property) { storing.append(property) }
        }
        for superclass in model.superclassStoring(of: declaration.name) where !storing.contains(superclass) {
            storing.append(superclass)
        }
        let storingSource = """
        /// A member of ``\(ontology.typeName)/\(names.className)`` that keeps its property values in an
        /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
        /// any module, conforms to it.
        \(access)protocol \(names.storing): \(storing.joined(separator: ", ")) {}
        """
        let qualifiedIndividual = "\(ontology.typeName).\(names.individual)"
        let properties = (model.ownRequirements(of: declaration.name).map { requirement in
            "[\(ontology.typeName).\(ClassNames(className: SwiftIdentifier.sanitized(requirement.declaration.name)).value).self]"
        } + model.refinements(of: declaration.name).map { ClassNames(qualifiedClass: $0).qualifiedIndividual + ".properties" })
            .joined(separator: " + ")
        let individualSource = """
        \(Documentation.docComment(for: declaration))\(access)final class \(names.individual): \(ontology.typeName).\(names.storing), RDFCore.ResourceClass, RDFCore.DecodableResource {
            \(memberAccess)static let classKey: RDFCore.TermKey? = \(key(of: declaration))

            \(memberAccess)static let classes: [any RDFCore.ResourceClass.Type] = [\(qualifiedIndividual).self]

            /// The properties a member of the class has, which a decoder reads:
            /// its own and its superclasses'.
            \(memberAccess)static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                \(properties)
            }

            /// A member of the class as a property value.
            \(memberAccess)typealias Member = \(model.memberType(ofClass: declaration.name))

            \(memberAccess)let storage = RDFCore.IndividualStorage()

            /// A member of the class that no declaration names: a blank node at the boundary.
            \(memberAccess)init() {}

            \(memberAccess)static func encodeDescription(to encoder: any Encoder) throws {
        \(description(of: declaration, indent: "        "))
            }
        }
        """
        return [protocolSource, storingSource, individualSource]
    }

    /// The declared key of a term this ontology declares.
    private func key(of declaration: ParsedEntity) -> String {
        "RDFCore.TermKey(\(Documentation.literal(declaration.name)), in: \(ontology.typeName).self)"
    }

    /// `public ` for members of a public or package ontology's types, which
    /// must be as visible as the protocols they witness.
    private var memberAccess: String { access }

    /// The statements that write what the declaration states about its term:
    /// `rdf:type`, `rdfs:subClassOf`, `rdfs:domain`, `rdfs:range`,
    /// `rdfs:label`, `rdfs:comment`, `rdfs:seeAlso` and `owl:deprecated`.
    private func description(of declaration: ParsedEntity, indent: String) -> String {
        var lines: [String] = []
        func classes(_ form: String) -> String {
            declaration.terms(form).map { spelling in
                ClassNames(qualifiedClass: ontology.spelling(of: ontology.resolve(spelling))).qualifiedIndividual + ".self"
            }.joined(separator: ", ")
        }
        if !declaration.terms("Type").isEmpty {
            lines.append("try container.encode([\(classes("Type"))] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.type.key))")
        }
        for (form, property) in [("SubClassOf", "RDF.subClassOf"), ("Domain", "RDF.domain"), ("Range", "RDF.range")] where !declaration.terms(form).isEmpty {
            lines.append("try container.encode([\(classes(form))] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(\(property).key))")
        }
        for (form, property) in [("Label", "RDF.label"), ("Comment", "RDF.comment")] {
            let texts = declaration.annotations(form).compactMap(\.text)
            if !texts.isEmpty {
                lines.append("try container.encode([\(texts.map { "RDFCore.Literal(\(Documentation.literal($0)))" }.joined(separator: ", "))], for: RDFCore.PropertyKey(\(property).key))")
            }
        }
        // The document `SeeAlso` names is a resource outside the runtime,
        // known only by its address: it is written as that IRI, and the
        // encoder makes it the object node, at the boundary.
        for document in declaration.annotations("SeeAlso").compactMap(\.text) {
            lines.append("try container.encode(IRIKit.IRI(validating: \(Documentation.literal(document))), forKey: RDFCore.PropertyKey(RDF.seeAlso.key))")
        }
        // `owl:deprecated true`: the `xsd:boolean` true, as a value of the
        // datatype's Swift type, which an encoder writes as its literal.
        if !declaration.annotations("Deprecated").isEmpty {
            lines.append(Self.deprecatedStatement.formatted().description)
        }
        guard !lines.isEmpty else { return "\(indent)_ = encoder.container(keyedBy: RDFCore.PropertyKey.self)" }
        return (["var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)"] + lines)
            .map { indent + $0 }.joined(separator: "\n")
    }

    /// `try container.encode([true] as [XSD.boolean], for: RDFCore.PropertyKey(OWL.deprecatedValue.key))`,
    /// built as syntax nodes.
    private static var deprecatedStatement: ExprSyntax {
        let values = AsExprSyntax(
            expression: ArrayExprSyntax(expressions: [ExprSyntax(BooleanLiteralExprSyntax(true))]),
            type: ArrayTypeSyntax(element: MemberTypeSyntax(baseType: IdentifierTypeSyntax(name: .identifier("XSD")), name: .identifier("boolean")))
        )
        let key = MemberAccessExprSyntax(
            base: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("OWL")), name: .identifier("deprecatedValue")),
            name: .identifier("key")
        )
        let property = FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("RDFCore")), name: .identifier("PropertyKey"))
        ) {
            LabeledExprSyntax(expression: key)
        }
        let encode = FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("container")), name: .identifier("encode"))
        ) {
            LabeledExprSyntax(expression: values)
            LabeledExprSyntax(label: "for", expression: property)
        }
        return ExprSyntax(TryExprSyntax(expression: encode))
    }

    // MARK: - Individuals

    /// The class of a named individual, which conforms to the storing
    /// protocol of each of its classes (ClassAssertion, OWL 2 Structural
    /// Specification §9.6.1) and carries its declared key, and the ontology
    /// member whose value is the individual.
    private func individualDeclarations(_ declaration: ParsedEntity) -> [String] {
        let name = SwiftIdentifier.escaped(declaration.name)
        let className = ClassNames(className: SwiftIdentifier.sanitized(declaration.name)).individual
        guard !collides([className], with: declaration) else { return [] }
        let classes = declaration.terms("Type").map { ClassNames(qualifiedClass: ontology.spelling(of: ontology.resolve($0))) }
        let conformances = classes.map(\.qualifiedStoring) + ["RDFCore.PropertyValueStoring"]
        return [
            """
            \(Documentation.docComment(for: declaration))\(access)var \(name): \(ontology.typeName).\(className) {
                \(ontology.typeName).\(className).individual
            }
            """,
            """
            /// The class of the named individual ``\(ontology.typeName)/\(declaration.name)``.
            \(access)final class \(className): \(conformances.joined(separator: ", ")) {
                \(memberAccess)static let key: RDFCore.TermKey? = \(key(of: declaration))

                \(memberAccess)static let classes: [any RDFCore.ResourceClass.Type] = [\(classes.map { $0.qualifiedIndividual + ".self" }.joined(separator: ", "))]

                \(memberAccess)let storage = RDFCore.IndividualStorage()

                /// The individual, the one instance of its class.
                static let individual = \(ontology.typeName).\(className)()

                private init() {}
            }
            """,
        ]
    }

    // MARK: - Properties

    /// The Swift class of the property's range, whose members a decoder
    /// makes for values the document gives no class: `rdfs:Resource`'s when
    /// the property has no `Range`.
    private func rangeClass(of declaration: ParsedEntity) -> String {
        guard let spelling = declaration.term("Range") else { return ClassNames(qualifiedClass: ClassNames.resource).qualifiedIndividual }
        return ClassNames(qualifiedClass: ontology.spelling(of: ontology.resolve(spelling))).qualifiedIndividual
    }

    /// The term type of a property, and, when a class of this ontology is
    /// its domain, the value type that holds its values on an individual
    /// (`Fauna.hasHabitatValue`) and the storing protocol that gives the
    /// individual its accessor (`Fauna.hasHabitatStoring`). The storing
    /// protocol of every domain refines it, so the property is one property,
    /// supplied once.
    private func propertyDeclarations(_ declaration: ParsedEntity) -> [String] {
        let name = SwiftIdentifier.escaped(declaration.name)
        let term = """
        \(Documentation.docComment(for: declaration))\(access)struct \(name): RDFCore.PropertyTerm {
            \(memberAccess)static let key = \(key(of: declaration))

            /// The property's description, which ``\(ontology.typeName)/ontology`` lists.
            \(memberAccess)init() {}

            \(memberAccess)func encode(to encoder: any Encoder) throws {
        \(description(of: declaration, indent: "        "))
            }
        }
        """
        guard model.isStored(declaration) else { return [term] }
        let names = ClassNames(className: SwiftIdentifier.sanitized(declaration.name))
        guard !collides([names.value, names.storing], with: declaration) else { return [term] }
        let requirement = model.requirement(for: declaration)
        return [
            term,
            """
            /// The values an individual has for ``\(ontology.typeName)/\(names.className)``.
            \(access)struct \(names.value): RDFCore.PropertyValue, Decodable {
                /// The declared key of the property, from which an encoder derives its IRI.
                \(memberAccess)static var key: RDFCore.TermKey {
                    \(ontology.typeName).\(name).key
                }

                \(memberAccess)var value: \(requirement.declaredType) = []

                \(memberAccess)init() {}

                \(memberAccess)init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: RDFCore.PropertyKey.self)
                    value = try container.decode(\(requirement.declaredType).self, for: RDFCore.PropertyKey(Self.key), as: \(rangeClass(of: declaration)).self)
                }

                \(memberAccess)func encode(to encoder: any Encoder) throws {
                    var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    try container.encode(value, for: RDFCore.PropertyKey(Self.key))
                }
            }
            """,
            """
            /// An individual that has ``\(ontology.typeName)/\(names.className)``.
            @IndividualStoring
            \(access)protocol \(names.storing): RDFCore.PropertyValueStoring {
                var \(requirement.name): \(requirement.declaredType) { get set }
            }
            """,
        ]
    }
}
