import Foundation
import SwiftDiagnostics
import SwiftSyntax
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
///   members (`Fauna.AnimalIndividual`). The class writes its own
///   description: the `Type`, `SubClassOf`, `Label`, `Comment`, `SeeAlso`
///   and `Deprecated` it is declared with.
/// - A datatype is a class whose members are literals.
/// - A property becomes a term type, which writes its own description
///   (`Type`, `Domain`, `Range`, `Label`, `Comment`, `SeeAlso`,
///   `Deprecated`), and a value type and storing protocol that keep its
///   values in an individual's ``RDFCore/IndividualStorage``.
/// - The ontology type gets `ontology`, the descriptions of its terms, the
///   way back to RDF, as a translated module has.
///
/// Each generated type's IRI is computed here from the namespace and emitted
/// as a literal, for the boundary only. Generated code never builds an
/// identity at runtime.
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
        var generated: Set<String> = []
        var descriptions: [String] = []
        let members = ontology.declarations.flatMap { declaration -> [DeclSyntax] in
            // A term declared twice gets one type.
            guard generated.insert(declaration.name).inserted, let shape = model.shape(of: declaration.name) else { return [] }
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
            }
            return sources.map { DeclSyntax(stringLiteral: $0) }
        }
        return members + [DeclSyntax(stringLiteral: ontologyDescriptions(descriptions))]
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
        let individualSource = """
        \(Documentation.docComment(for: declaration))\(access)final class \(names.individual): \(ontology.typeName).\(names.storing), RDFCore.ResourceClass {
            \(memberAccess)static let iri: IRIKit.IRI? = \(Documentation.literal(ontology.iri(of: declaration.name)))

            \(memberAccess)static let classes: [any RDFCore.ResourceClass.Type] = [\(qualifiedIndividual).self]

            /// A member of the class as a property value.
            \(memberAccess)typealias Member = \(model.memberType(ofClass: declaration.name))

            \(memberAccess)let iri: IRIKit.IRI?

            \(memberAccess)let storage = RDFCore.IndividualStorage()

            /// A member of the class, denoted by `iri`, or a blank node when it is `nil`.
            \(memberAccess)init(iri: IRIKit.IRI? = nil) {
                self.iri = iri
            }

            \(memberAccess)static func encodeDescription(to encoder: any Encoder) throws {
        \(description(of: declaration, indent: "        "))
            }
        }
        """
        return [protocolSource, storingSource, individualSource]
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
            lines.append("try container.encode([\(classes("Type"))] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.type))")
        }
        for (form, property) in [("SubClassOf", "RDF.subClassOf"), ("Domain", "RDF.domain"), ("Range", "RDF.range")] where !declaration.terms(form).isEmpty {
            lines.append("try container.encode([\(classes(form))] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(\(property)))")
        }
        for (form, property) in [("Label", "RDF.label"), ("Comment", "RDF.comment")] {
            let texts = declaration.annotations(form).compactMap(\.text)
            if !texts.isEmpty {
                lines.append("try container.encode([\(texts.map { "RDFCore.Literal(\(Documentation.literal($0)))" }.joined(separator: ", "))], for: RDFCore.PropertyKey(\(property)))")
            }
        }
        let documents = declaration.annotations("SeeAlso").compactMap(\.text)
        if !documents.isEmpty {
            lines.append("try container.encode([\(documents.map { "RDF.ResourceIndividual(iri: \(Documentation.literal($0)))" }.joined(separator: ", "))] as [any RDFCore.Resource], for: RDFCore.PropertyKey(RDF.seeAlso))")
        }
        if !declaration.annotations("Deprecated").isEmpty {
            lines.append("try container.encode([try RDFCore.Literal(\"true\", datatype: \"http://www.w3.org/2001/XMLSchema#boolean\")], for: RDFCore.PropertyKey(OWL.deprecated))")
        }
        guard !lines.isEmpty else { return "\(indent)_ = encoder.container(keyedBy: RDFCore.PropertyKey.self)" }
        return (["var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)"] + lines)
            .map { indent + $0 }.joined(separator: "\n")
    }

    // MARK: - Properties

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
            \(memberAccess)static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))

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
            \(access)struct \(names.value): RDFCore.PropertyValue {
                \(memberAccess)var value: \(requirement.declaredType) = []

                \(memberAccess)init() {}

                \(memberAccess)func encode(to encoder: any Encoder) throws {
                    var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    try container.encode(value, for: RDFCore.PropertyKey(\(ontology.typeName).\(name).metadata))
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
