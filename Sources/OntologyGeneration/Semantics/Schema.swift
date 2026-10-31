/// What a set of vocabularies' statements entail about their own terms,
/// under the published semantics: which terms are classes, properties or
/// individuals, which classes are the root and the empty class, and which
/// classes' members are classes, properties or literals.
///
/// Nothing here names a term. The predicates come from the RDFS entailment
/// patterns that use them (`rdf:type` and `rdfs:subClassOf` from rdfs8,
/// `rdfs:domain` from rdfs2, `rdfs:range` from rdfs3), the built-in classes
/// from the parts of the universe of OWL 2 RDF-Based Semantics (`IR` is the
/// extension of `rdfs:Resource`), and their relations from its conditions
/// on class extensions, read as axioms: `owl:Thing ∈ IC, = IR` makes
/// `owl:Thing` and `rdfs:Resource` the same class (D7), and
/// `owl:FunctionalProperty ∈ IC, ⊆ IP` makes it a subclass of
/// `rdf:Property`. The statements are then closed under the RDFS entailment
/// patterns.
public struct Schema: Sendable {
    public struct Triple: Hashable, Sendable {
        public let subject: String
        public let predicate: String
        public let object: String

        public init(_ subject: String, _ predicate: String, _ object: String) {
            self.subject = subject
            self.predicate = predicate
            self.object = object
        }
    }

    /// The statements and what they entail.
    public let triples: Set<Triple>

    /// `rdf:type`, `rdfs:subClassOf`, `rdfs:domain` and `rdfs:range`.
    public let type: String
    public let subClassOf: String
    public let domain: String
    public let range: String

    /// The class whose extension is the universe, `IR`: the root (D7).
    public let root: String
    /// The classes whose extension is the universe (`= IR`), the root
    /// included, and those whose extension is empty (`= ∅`).
    public let universal: Set<String>
    public let empty: Set<String>
    /// The classes of classes (`IC`), properties (`IP`) and literal values
    /// (`LV`).
    public let classOfClasses: String
    public let classOfProperties: String
    public let classOfLiterals: String
    /// The classes of the properties that have at most one value (OWL 2 RL
    /// prp-fp, D5).
    public let functional: Set<String>
    /// The class of annotation properties (`IOAP`).
    public let classOfAnnotationProperties: String?

    public init(_ statements: [Triple], semantics: Semantics = publishedSemantics) {
        let rdfs8 = semantics.rule(named: "rdfs8")!
        let rdfs2 = semantics.rule(named: "rdfs2")!
        let rdfs3 = semantics.rule(named: "rdfs3")!
        type = rdfs8.premises[0].predicate.iri!
        subClassOf = rdfs8.conclusions[0].predicate.iri!
        domain = rdfs2.premises[0].predicate.iri!
        range = rdfs3.premises[0].predicate.iri!

        func part(_ name: String) -> String? { semantics.parts.first { $0.name == name }?.class }
        root = part("IR")!
        classOfClasses = part("IC")!
        classOfProperties = part("IP")!
        classOfLiterals = part("LV")!
        classOfAnnotationProperties = part("IOAP")

        // The conditions of OWL 2 RDF-Based Semantics as axioms.
        var axioms = statements
        for part in semantics.parts {
            guard let subset = part.class else { continue }
            for superset in part.supersets {
                if let superclass = semantics.parts.first(where: { $0.name == superset })?.class {
                    axioms.append(Triple(subset, subClassOf, superclass))
                }
            }
        }
        var empty: Set<String> = []
        for condition in semantics.classExtensions {
            if condition.part == "∅" {
                empty.insert(condition.class)
                continue
            }
            guard let extent = semantics.parts.first(where: { $0.name == condition.part })?.class else { continue }
            axioms.append(Triple(condition.class, subClassOf, extent))
            if condition.isEqual { axioms.append(Triple(extent, subClassOf, condition.class)) }
        }
        for membership in semantics.propertyExtensions {
            if let extent = semantics.parts.first(where: { $0.name == membership.part })?.class {
                axioms.append(Triple(membership.property, type, extent))
            }
        }
        self.empty = empty
        let closure = Self.closure(of: axioms, under: semantics.rdfsEntailment)
        triples = closure

        let subClassOf = subClassOf
        let root = root
        let type = type
        universal = Set(closure.filter { $0.predicate == subClassOf && $0.object == root }.map(\.subject).filter {
            closure.contains(Triple(root, subClassOf, $0))
        }).union([root])
        functional = Set(semantics.rule(named: "prp-fp").map { rule in
            rule.premises.filter { $0.predicate.iri == type }.compactMap(\.object.iri)
        } ?? [])
    }

    /// The statements closed under the rules whose premises and conclusions
    /// are all triple patterns.
    static func closure(of statements: [Triple], under rules: [EntailmentRule]) -> Set<Triple> {
        var triples = Set(statements)
        var changed = true
        while changed {
            changed = false
            for rule in rules where !rule.isInconsistency {
                let index = Dictionary(grouping: triples, by: \.predicate)
                for binding in bindings(of: rule.premises, in: index) {
                    for conclusion in rule.conclusions {
                        guard let triple = instance(of: conclusion, under: binding) else { continue }
                        if triples.insert(triple).inserted { changed = true }
                    }
                }
            }
        }
        return triples
    }

    /// The bindings of the variables under which every premise is one of
    /// the triples, which are grouped by predicate.
    static func bindings(of premises: [TriplePattern], in triples: [String: [Triple]]) -> [[String: String]] {
        var bindings: [[String: String]] = [[:]]
        for premise in premises {
            bindings = bindings.flatMap { binding -> [[String: String]] in
                let candidates: [Triple]
                switch premise.predicate {
                case .iri(let predicate): candidates = triples[predicate] ?? []
                case .variable(let name): candidates = binding[name].map { triples[$0] ?? [] } ?? triples.values.flatMap { $0 }
                }
                return candidates.compactMap { triple in match(premise, triple, binding) }
            }
            if bindings.isEmpty { break }
        }
        return bindings
    }

    private static func match(_ pattern: TriplePattern, _ triple: Triple, _ binding: [String: String]) -> [String: String]? {
        var binding = binding
        for (term, value) in [(pattern.subject, triple.subject), (pattern.predicate, triple.predicate), (pattern.object, triple.object)] {
            switch term {
            case .iri(let iri):
                guard iri == value else { return nil }
            case .variable(let name):
                if let bound = binding[name] {
                    guard bound == value else { return nil }
                } else {
                    binding[name] = value
                }
            }
        }
        return binding
    }

    private static func instance(of pattern: TriplePattern, under binding: [String: String]) -> Triple? {
        func value(_ term: PatternTerm) -> String? {
            switch term {
            case .iri(let iri): iri
            case .variable(let name): binding[name]
            }
        }
        guard let subject = value(pattern.subject), let predicate = value(pattern.predicate), let object = value(pattern.object) else { return nil }
        return Triple(subject, predicate, object)
    }

    // MARK: - What the statements entail

    /// The classes a term is an instance of.
    public func types(of term: String) -> Set<String> {
        Set(triples.filter { $0.subject == term && $0.predicate == type }.map(\.object))
    }

    public func isSubclass(_ term: String, of superclass: String) -> Bool {
        triples.contains(Triple(term, subClassOf, superclass))
    }

    /// Whether a term is a class: an instance of the class of classes.
    public func isClass(_ term: String) -> Bool {
        types(of: term).contains(classOfClasses)
    }

    /// Whether a term is a property: an instance of the class of properties.
    public func isProperty(_ term: String) -> Bool {
        types(of: term).contains(classOfProperties)
    }

    /// Whether a class's members are classes or properties, so that a
    /// property whose domain it is describes a type, not an individual.
    public func describesTypes(_ term: String) -> Bool {
        isSubclass(term, of: classOfClasses) || isSubclass(term, of: classOfProperties)
    }

    /// Whether a class's members are literal values, Swift value types (D6).
    public func isLiteralClass(_ term: String) -> Bool {
        isSubclass(term, of: classOfLiterals)
    }

    /// Whether a property has at most one value (D5).
    public func isFunctional(_ property: String) -> Bool {
        !types(of: property).isDisjoint(with: functional)
    }

    /// Whether a property is an annotation property, documentation (D8).
    public func isAnnotationProperty(_ property: String) -> Bool {
        classOfAnnotationProperties.map { types(of: property).contains($0) } ?? false
    }
}
