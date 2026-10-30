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
///
/// Every declaration is built from SwiftSyntax's typed nodes; the macro
/// system formats them.
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
        var descriptions: [ExprSyntax] = []
        let members = ontology.declarations.flatMap { declaration -> [DeclSyntax] in
            // A term declared twice gets one type.
            guard generated.insert(declaration.name).inserted, let shape = model.shape(of: declaration.name) else { return [] }
            let declarations: [DeclSyntax]
            switch shape {
            case .class, .datatype:
                declarations = classDeclarations(declaration)
                if declarations.count > 1 {
                    descriptions.append(rdfCore("ClassDescription").expression.call(LabeledExprSyntax(expression: individualClass(of: declaration).expression.dotSelf)))
                }
            case .property:
                declarations = propertyDeclarations(declaration)
                descriptions.append(self.declared(declaration.name).expression.call())
            case .individual:
                declarations = individualDeclarations(declaration)
                if !declarations.isEmpty { descriptions.append(.named(declaration.name)) }
            }
            return declarations
        }
        let namespace = VariableDeclSyntax(
            leadingTrivia: .documentation([
                "The namespace this ontology's terms are declared in, from which an",
                "encoder derives each term's IRI.",
            ]),
            modifiers: access.andStatic,
            .let,
            .identifier("namespace"),
            value: .string(ontology.namespace)
        )
        return members + [ontologyDescriptions(descriptions), DeclSyntax(namespace)]
    }

    /// `ontology`: the description of every term the ontology declares, the
    /// way back to RDF, as a translated module's `ontology` is.
    private func ontologyDescriptions(_ descriptions: [ExprSyntax]) -> DeclSyntax {
        DeclSyntax(VariableDeclSyntax(
            leadingTrivia: .documentation([
                "The descriptions of the terms this ontology declares.",
                "",
                "Encoding them gives the ontology's graph:",
                "",
                "    let document = try TurtleEncoder().encode(\(ontology.typeName)().ontology)",
            ]),
            modifiers: access,
            .var,
            .identifier("ontology"),
            type: .array(.any(rdfCore("Description").type)),
            accessors: .getter(ExprSyntax.list(descriptions))
        ))
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

    /// `public` or `package` for a public or package ontology's types and
    /// their members, which must be as visible as the protocols they witness.
    private var access: DeclModifierListSyntax { DeclModifierListSyntax(access: ontology.access) }

    // MARK: - Names

    /// A name declared in this ontology: `Fauna.Animal`.
    private func declared(_ name: String) -> QualifiedName {
        QualifiedName(ontology.typeName, name)
    }

    /// A type of the runtime: `RDFCore.Literal`.
    private func rdfCore(_ name: String) -> QualifiedName {
        QualifiedName("RDFCore", name)
    }

    /// The Swift class of a class this ontology declares: `Fauna.AnimalIndividual`.
    private func individualClass(of declaration: ParsedEntity) -> QualifiedName {
        declared(ClassNames(className: SwiftIdentifier.sanitized(declaration.name)).individual)
    }

    /// The Swift class of a class an annotation names, here or in another
    /// module: `RDF.ClassIndividual` for `RDF.Class`.
    private func individualClass(named spelling: String) -> QualifiedName {
        ClassNames(qualifiedClass: ontology.name(of: ontology.resolve(spelling))).qualifiedIndividual
    }

    /// The declared key of a term this ontology declares:
    /// `RDFCore.TermKey("Animal", in: Fauna.self)`.
    private func key(of declaration: ParsedEntity) -> ExprSyntax {
        rdfCore("TermKey").expression.call(
            LabeledExprSyntax(expression: ExprSyntax.string(declaration.name)),
            LabeledExprSyntax("in", QualifiedName(ontology.typeName).expression.dotSelf)
        )
    }

    // MARK: - Classes

    private func classDeclarations(_ declaration: ParsedEntity) -> [DeclSyntax] {
        let names = ClassNames(className: SwiftIdentifier.sanitized(declaration.name))
        let requirements = model.ownRequirements(of: declaration.name).map { requirement in
            DeclSyntax(VariableDeclSyntax(
                leadingTrivia: Documentation.trivia(for: requirement.declaration),
                attributes: Documentation.attributes(for: requirement.declaration),
                .var,
                requirement.name,
                type: requirement.declaredType,
                accessors: .getSet
            ))
        }
        let classProtocol = DeclSyntax(ProtocolDeclSyntax(
            leadingTrivia: Documentation.trivia(for: declaration),
            attributes: Documentation.attributes(for: declaration),
            modifiers: access,
            name: .declared(declaration.name),
            inheritanceClause: InheritanceClauseSyntax(model.refinements(of: declaration.name).map(\.type)),
            memberBlock: MemberBlockSyntax(spaced: requirements)
        ))
        guard !collides([names.storing, names.individual], with: declaration) else { return [classProtocol] }

        var storing = [declared(declaration.name)]
        for requirement in model.ownRequirements(of: declaration.name) {
            let property = declared(ClassNames(className: SwiftIdentifier.sanitized(requirement.declaration.name)).storing)
            if !storing.contains(property) { storing.append(property) }
        }
        for superclass in model.superclassStoring(of: declaration.name) where !storing.contains(superclass) {
            storing.append(superclass)
        }
        let storingProtocol = DeclSyntax(ProtocolDeclSyntax(
            leadingTrivia: .documentation([
                "A member of ``\(ontology.typeName)/\(names.className)`` that keeps its property values in an",
                "``RDFCore/IndividualStorage``. An individual typed with the class, in",
                "any module, conforms to it.",
            ]),
            modifiers: access,
            name: .declared(names.storing),
            inheritanceClause: InheritanceClauseSyntax(storing.map(\.type)),
            memberBlock: MemberBlockSyntax([])
        ))

        let ownProperties = model.ownRequirements(of: declaration.name).map { requirement in
            ExprSyntax.array([declared(ClassNames(className: SwiftIdentifier.sanitized(requirement.declaration.name)).value).expression.dotSelf])
        }
        let inheritedProperties = model.refinements(of: declaration.name).map { refined in
            ClassNames(qualifiedClass: refined).qualifiedIndividual.expression.member("properties")
        }
        let properties = (ownProperties + inheritedProperties).dropFirst().reduce((ownProperties + inheritedProperties)[0]) { $0.plus($1) }
        let individualClass = DeclSyntax(ClassDeclSyntax(
            leadingTrivia: Documentation.trivia(for: declaration),
            attributes: Documentation.attributes(for: declaration),
            modifiers: access + [DeclModifierSyntax(name: .keyword(.final))],
            name: .declared(names.individual),
            inheritanceClause: InheritanceClauseSyntax([
                declared(names.storing).type,
                rdfCore("ResourceClass").type,
                rdfCore("DecodableResource").type,
            ]),
            memberBlock: MemberBlockSyntax(spaced: [
                DeclSyntax(VariableDeclSyntax(
                    modifiers: access.andStatic,
                    .let,
                    .identifier("classKey"),
                    type: TypeSyntax(OptionalTypeSyntax(wrappedType: rdfCore("TermKey").type)),
                    value: key(of: declaration)
                )),
                DeclSyntax(VariableDeclSyntax(
                    modifiers: access.andStatic,
                    .let,
                    .identifier("classes"),
                    type: .array(.any(.metatype(rdfCore("ResourceClass").type))),
                    value: .array([self.individualClass(of: declaration).expression.dotSelf])
                )),
                DeclSyntax(VariableDeclSyntax(
                    leadingTrivia: .documentation([
                        "The properties a member of the class has, which a decoder reads:",
                        "its own and its superclasses'.",
                    ]),
                    modifiers: access.andStatic,
                    .var,
                    .identifier("properties"),
                    type: .array(.any(.metatype(.composition([rdfCore("PropertyValue").type, QualifiedName("Decodable").type])))),
                    accessors: .getter(properties)
                )),
                DeclSyntax(TypeAliasDeclSyntax(
                    leadingTrivia: .documentation(["A member of the class as a property value."]),
                    modifiers: access,
                    name: .identifier("Member"),
                    initializer: TypeInitializerClauseSyntax(value: model.memberType(ofClass: declaration.name))
                )),
                DeclSyntax(VariableDeclSyntax(
                    modifiers: access,
                    .let,
                    .identifier("storage"),
                    value: rdfCore("IndividualStorage").expression.call()
                )),
                initializer(
                    documentation: ["A member of the class that no declaration names: a blank node at the boundary."],
                    modifiers: access
                ),
                encodeFunction(
                    named: "encodeDescription",
                    modifiers: access.andStatic,
                    body: description(of: declaration)
                ),
            ])
        ))
        return [classProtocol, storingProtocol, individualClass]
    }

    /// `init() {}`, documented.
    private func initializer(documentation: [String] = [], modifiers: DeclModifierListSyntax) -> DeclSyntax {
        DeclSyntax(InitializerDeclSyntax(
            leadingTrivia: .documentation(documentation),
            modifiers: modifiers,
            signature: FunctionSignatureSyntax(parameterClause: FunctionParameterClauseSyntax([])),
            body: CodeBlockSyntax([])
        ))
    }

    /// `func name(to encoder: any Encoder) throws { body }`.
    private func encodeFunction(named name: String, modifiers: DeclModifierListSyntax, body: [CodeBlockItemSyntax.Item]) -> DeclSyntax {
        DeclSyntax(FunctionDeclSyntax(
            modifiers: modifiers,
            name: .identifier(name),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax([(label: "to", name: "encoder", type: .any(QualifiedName("Encoder").type))]),
                effectSpecifiers: .throwing
            ),
            body: CodeBlockSyntax(body)
        ))
    }

    /// `encoder.container(keyedBy: RDFCore.PropertyKey.self)`.
    private var container: ExprSyntax {
        ExprSyntax.named("encoder").member("container").call(LabeledExprSyntax("keyedBy", rdfCore("PropertyKey").expression.dotSelf))
    }

    /// `RDFCore.PropertyKey(key)`.
    private func propertyKey(_ key: some ExprSyntaxProtocol) -> ExprSyntax {
        rdfCore("PropertyKey").expression.call(LabeledExprSyntax(expression: key))
    }

    /// `try container.encode(values, for: RDFCore.PropertyKey(key))`.
    private func encode(_ values: some ExprSyntaxProtocol, for key: some ExprSyntaxProtocol) -> CodeBlockItemSyntax.Item {
        .expr(ExprSyntax.named("container").member("encode").call(
            LabeledExprSyntax(expression: values),
            LabeledExprSyntax("for", propertyKey(key))
        ).tried)
    }

    /// The statements that write what the declaration states about its term:
    /// `rdf:type`, `rdfs:subClassOf`, `rdfs:domain`, `rdfs:range`,
    /// `rdfs:label`, `rdfs:comment`, `rdfs:seeAlso` and `owl:deprecated`.
    private func description(of declaration: ParsedEntity) -> [CodeBlockItemSyntax.Item] {
        var statements: [CodeBlockItemSyntax.Item] = []
        func classes(_ form: String) -> ExprSyntax {
            ExprSyntax.array(declaration.terms(form).map { individualClass(named: $0).expression.dotSelf })
                .as(TypeSyntax.array(.any(.metatype(rdfCore("ResourceClass").type))))
        }
        let forms: [(form: String, property: String)] = [("Type", "type"), ("SubClassOf", "subClassOf"), ("Domain", "domain"), ("Range", "range")]
        for (form, property) in forms where !declaration.terms(form).isEmpty {
            statements.append(encode(classes(form), for: QualifiedName("RDF", property, "key").expression))
        }
        for (form, property) in [("Label", "label"), ("Comment", "comment")] {
            let texts = declaration.annotations(form).compactMap(\.text)
            if !texts.isEmpty {
                let literals = texts.map { rdfCore("Literal").expression.call(LabeledExprSyntax(expression: ExprSyntax.string($0))) }
                statements.append(encode(ExprSyntax.array(literals), for: QualifiedName("RDF", property, "key").expression))
            }
        }
        // A document `SeeAlso` names is a resource outside the runtime,
        // dereferenced by its IRI: its declared key is the document's IRI as
        // a namespace with no local name.
        for (index, document) in declaration.annotations("SeeAlso").compactMap(\.text).enumerated() {
            let namespace = "SeeAlsoNamespace\(index)"
            let resource = "SeeAlsoDocument\(index)"
            statements.append(.decl(DeclSyntax(StructDeclSyntax(
                name: .identifier(namespace),
                inheritanceClause: InheritanceClauseSyntax([rdfCore("Vocabulary").type]),
                memberBlock: MemberBlockSyntax([
                    DeclSyntax(VariableDeclSyntax(
                        modifiers: DeclModifierListSyntax(access: "").andStatic,
                        .var,
                        .identifier("namespace"),
                        type: QualifiedName("String").type,
                        accessors: .getter(ExprSyntax.string(document))
                    )),
                ])
            ))))
            statements.append(.decl(DeclSyntax(ClassDeclSyntax(
                modifiers: [DeclModifierSyntax(name: .keyword(.final))],
                name: .identifier(resource),
                inheritanceClause: InheritanceClauseSyntax([rdfCore("Resource").type]),
                memberBlock: MemberBlockSyntax([
                    DeclSyntax(VariableDeclSyntax(
                        modifiers: DeclModifierListSyntax(access: "").andStatic,
                        .var,
                        .identifier("key"),
                        type: TypeSyntax(OptionalTypeSyntax(wrappedType: rdfCore("TermKey").type)),
                        accessors: .getter(rdfCore("TermKey").expression.call(
                            LabeledExprSyntax(expression: ExprSyntax.string("")),
                            LabeledExprSyntax("in", QualifiedName(namespace).expression.dotSelf)
                        ))
                    )),
                    encodeFunction(named: "encode", modifiers: [], body: []),
                ])
            ))))
            statements.append(encode(
                ExprSyntax.array([QualifiedName(resource).expression.call()]).as(TypeSyntax.array(.any(rdfCore("Resource").type))),
                for: QualifiedName("RDF", "seeAlso", "key").expression
            ))
        }
        if !declaration.annotations("Deprecated").isEmpty {
            let literal = rdfCore("Literal").expression.call(
                LabeledExprSyntax(expression: ExprSyntax.string("true")),
                LabeledExprSyntax("datatype", ExprSyntax.string("http://www.w3.org/2001/XMLSchema#boolean"))
            ).tried
            statements.append(encode(ExprSyntax.array([literal]), for: QualifiedName("OWL", "deprecatedValue", "key").expression))
        }
        guard !statements.isEmpty else {
            return [.expr(ExprSyntax(DiscardAssignmentExprSyntax()).assigned(container))]
        }
        let containerDeclaration = VariableDeclSyntax(.var, .identifier("container"), value: container)
        return [.decl(DeclSyntax(containerDeclaration))] + statements
    }

    // MARK: - Individuals

    /// The class of a named individual, which conforms to the storing
    /// protocol of each of its classes (ClassAssertion, OWL 2 Structural
    /// Specification §9.6.1) and carries its declared key, and the ontology
    /// member whose value is the individual.
    private func individualDeclarations(_ declaration: ParsedEntity) -> [DeclSyntax] {
        let className = ClassNames(className: SwiftIdentifier.sanitized(declaration.name)).individual
        guard !collides([className], with: declaration) else { return [] }
        let classes = declaration.terms("Type").map { ClassNames(qualifiedClass: ontology.name(of: ontology.resolve($0))) }
        let conformances = classes.map(\.qualifiedStoring.type) + [rdfCore("PropertyValueStoring").type]
        let individualClass = declared(className)
        return [
            DeclSyntax(VariableDeclSyntax(
                leadingTrivia: Documentation.trivia(for: declaration),
                attributes: Documentation.attributes(for: declaration),
                modifiers: access,
                .var,
                .declared(declaration.name),
                type: individualClass.type,
                accessors: .getter(individualClass.expression.member("individual"))
            )),
            DeclSyntax(ClassDeclSyntax(
                leadingTrivia: .documentation(["The class of the named individual ``\(ontology.typeName)/\(declaration.name)``."]),
                modifiers: access + [DeclModifierSyntax(name: .keyword(.final))],
                name: .declared(className),
                inheritanceClause: InheritanceClauseSyntax(conformances),
                memberBlock: MemberBlockSyntax(spaced: [
                    DeclSyntax(VariableDeclSyntax(
                        modifiers: access.andStatic,
                        .let,
                        .identifier("key"),
                        type: TypeSyntax(OptionalTypeSyntax(wrappedType: rdfCore("TermKey").type)),
                        value: key(of: declaration)
                    )),
                    DeclSyntax(VariableDeclSyntax(
                        modifiers: access.andStatic,
                        .let,
                        .identifier("classes"),
                        type: .array(.any(.metatype(rdfCore("ResourceClass").type))),
                        value: .array(classes.map { $0.qualifiedIndividual.expression.dotSelf })
                    )),
                    DeclSyntax(VariableDeclSyntax(
                        modifiers: access,
                        .let,
                        .identifier("storage"),
                        value: rdfCore("IndividualStorage").expression.call()
                    )),
                    DeclSyntax(VariableDeclSyntax(
                        leadingTrivia: .documentation(["The individual, the one instance of its class."]),
                        modifiers: [DeclModifierSyntax(name: .keyword(.static))],
                        .let,
                        .identifier("individual"),
                        value: individualClass.expression.call()
                    )),
                    initializer(modifiers: [DeclModifierSyntax(name: .keyword(.private))]),
                ])
            )),
        ]
    }

    // MARK: - Properties

    /// The Swift class of the property's range, whose members a decoder
    /// makes for values the document gives no class: `rdfs:Resource`'s when
    /// the property has no `Range`.
    private func rangeClass(of declaration: ParsedEntity) -> QualifiedName {
        guard let spelling = declaration.term("Range") else { return ClassNames(qualifiedClass: ClassNames.resource).qualifiedIndividual }
        return individualClass(named: spelling)
    }

    /// The term type of a property, and, when a class of this ontology is
    /// its domain, the value type that holds its values on an individual
    /// (`Fauna.hasHabitatValue`) and the storing protocol that gives the
    /// individual its accessor (`Fauna.hasHabitatStoring`). The storing
    /// protocol of every domain refines it, so the property is one property,
    /// supplied once.
    private func propertyDeclarations(_ declaration: ParsedEntity) -> [DeclSyntax] {
        let term = DeclSyntax(StructDeclSyntax(
            leadingTrivia: Documentation.trivia(for: declaration),
            attributes: Documentation.attributes(for: declaration),
            modifiers: access,
            name: .declared(declaration.name),
            inheritanceClause: InheritanceClauseSyntax([rdfCore("PropertyTerm").type]),
            memberBlock: MemberBlockSyntax(spaced: [
                DeclSyntax(VariableDeclSyntax(
                    modifiers: access.andStatic,
                    .let,
                    .identifier("key"),
                    value: key(of: declaration)
                )),
                initializer(
                    documentation: ["The property's description, which ``\(ontology.typeName)/ontology`` lists."],
                    modifiers: access
                ),
                encodeFunction(named: "encode", modifiers: access, body: description(of: declaration)),
            ])
        ))
        guard model.isStored(declaration) else { return [term] }
        let names = ClassNames(className: SwiftIdentifier.sanitized(declaration.name))
        guard !collides([names.value, names.storing], with: declaration) else { return [term] }
        let requirement = model.requirement(for: declaration)
        let selfKey = propertyKey(ExprSyntax.keyword(.Self).member("key"))
        let value = DeclSyntax(StructDeclSyntax(
            leadingTrivia: .documentation(["The values an individual has for ``\(ontology.typeName)/\(names.className)``."]),
            modifiers: access,
            name: .declared(names.value),
            inheritanceClause: InheritanceClauseSyntax([rdfCore("PropertyValue").type, QualifiedName("Decodable").type]),
            memberBlock: MemberBlockSyntax(spaced: [
                DeclSyntax(VariableDeclSyntax(
                    leadingTrivia: .documentation(["The declared key of the property, from which an encoder derives its IRI."]),
                    modifiers: access.andStatic,
                    .var,
                    .identifier("key"),
                    type: rdfCore("TermKey").type,
                    accessors: .getter(declared(declaration.name).expression.member("key"))
                )),
                DeclSyntax(VariableDeclSyntax(
                    modifiers: access,
                    .var,
                    .identifier("value"),
                    type: requirement.declaredType,
                    value: .array([])
                )),
                initializer(modifiers: access),
                DeclSyntax(InitializerDeclSyntax(
                    modifiers: access,
                    signature: FunctionSignatureSyntax(
                        parameterClause: FunctionParameterClauseSyntax([(label: "from", name: "decoder", type: .any(QualifiedName("Decoder").type))]),
                        effectSpecifiers: .throwing
                    ),
                    body: CodeBlockSyntax([
                        .decl(DeclSyntax(VariableDeclSyntax(
                            .let,
                            .identifier("container"),
                            value: ExprSyntax.named("decoder").member("container")
                                .call(LabeledExprSyntax("keyedBy", rdfCore("PropertyKey").expression.dotSelf)).tried
                        ))),
                        .expr(ExprSyntax.named("value").assigned(ExprSyntax.named("container").member("decode").call(
                            LabeledExprSyntax(expression: ExprSyntax.type(requirement.declaredType).dotSelf),
                            LabeledExprSyntax("for", selfKey),
                            LabeledExprSyntax("as", rangeClass(of: declaration).expression.dotSelf)
                        ).tried)),
                    ])
                )),
                encodeFunction(named: "encode", modifiers: access, body: [
                    .decl(DeclSyntax(VariableDeclSyntax(.var, .identifier("container"), value: container))),
                    .expr(ExprSyntax.named("container").member("encode").call(
                        LabeledExprSyntax(expression: ExprSyntax.named("value")),
                        LabeledExprSyntax("for", selfKey)
                    ).tried),
                ]),
            ])
        ))
        let storing = DeclSyntax(ProtocolDeclSyntax(
            leadingTrivia: .documentation(["An individual that has ``\(ontology.typeName)/\(names.className)``."]),
            attributes: [.attribute(AttributeSyntax(
                attributeName: IdentifierTypeSyntax(name: .identifier("IndividualStoring")),
                trailingTrivia: .newline
            ))],
            modifiers: access,
            name: .declared(names.storing),
            inheritanceClause: InheritanceClauseSyntax([rdfCore("PropertyValueStoring").type]),
            memberBlock: MemberBlockSyntax([
                DeclSyntax(VariableDeclSyntax(.var, requirement.name, type: requirement.declaredType, accessors: .getSet)),
            ])
        ))
        return [term, value, storing]
    }
}
