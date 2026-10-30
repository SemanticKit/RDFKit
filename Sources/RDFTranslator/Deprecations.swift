import RDFCore

/// The nodes whose Swift is `@available(*, deprecated)`.
///
/// `owl:deprecated true` is `@available(*, deprecated)` (DESIGN-CONTRACT
/// rule 6), and Swift warns wherever a declaration that is not deprecated
/// names one that is. So besides the resources the documents state are
/// deprecated, a resource whose Swift names a deprecated declaration is
/// deprecated too: a class whose protocol refines a deprecated class's, an
/// individual of a deprecated class, a class or property whose description
/// names a deprecated resource. A generated module then compiles without
/// warnings, and only code that uses a deprecated declaration is warned.
///
/// A property's value type and storing protocol name no deprecated
/// declaration, so they are never deprecated, and the classes whose members
/// have the property are not: only its term type and its accessor are.
struct Deprecations {
    private var nodes: Set<SubjectTerm> = []

    /// No node deprecated.
    init() {}

    /// The nodes deprecated in the Swift `scope` names.
    init(_ scope: some DeclarationScope, _ vocabulary: Vocabulary) {
        let candidates = scope.lower.modules.flatMap(\.order).filter(scope.lower.declares)
            + scope.declarations.order + scope.declarations.additions
        nodes = Set(candidates.filter(vocabulary.isDeprecated))
        var changed = true
        while changed {
            changed = false
            for node in candidates where !nodes.contains(node) {
                guard !scope.references(of: node, in: vocabulary).isDisjoint(with: nodes) else { continue }
                nodes.insert(node)
                changed = true
            }
        }
    }

    /// Whether the Swift of `node` is deprecated.
    func contains(_ node: SubjectTerm) -> Bool {
        nodes.contains(node)
    }

    /// Whether a combination class names a deprecated class.
    func contains(_ combination: Combination) -> Bool {
        combination.storing.contains { $0.class.map(contains) ?? false }
    }

    /// `@available(*, deprecated)` on its own line, when `deprecated`.
    static func attribute(_ deprecated: Bool, indent: String = "") -> String {
        deprecated ? indent + "@available(*, deprecated)\n" : ""
    }
}

extension DeclarationScope {
    /// The nodes whose declarations the Swift of `node` names outside the
    /// deprecated context of `described` and `ontology`.
    func references(of node: SubjectTerm, in vocabulary: Vocabulary) -> Set<SubjectTerm> {
        var references: Set<SubjectTerm> = []
        if let declaration = classDeclaration(node) {
            references.formUnion(declaration.conformances)
            references.formUnion(declaration.storing.compactMap(\.class))
            references.formUnion(declarations.refinements[node] ?? [])
        } else if let declaration = declarations.individuals[node] ?? lower.individual(node) {
            // An individual's description is its values, which `described`
            // sets in the deprecated context; its Swift class names its
            // classes.
            switch declaration.instanceOf {
            case .class(let type): references.insert(type)
            case .combination: references.formUnion(declaration.conformances)
            }
            references.remove(node)
            return references
        }
        // A class's and a property's descriptions name the objects of the
        // triples about them.
        for triple in vocabulary.graph where triple.subject == node {
            if let object = triple.object.node { references.insert(object) }
        }
        references.remove(node)
        return references
    }
}
