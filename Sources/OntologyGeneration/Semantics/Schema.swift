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
    public var triples: Set<Triple> { index.set }

    /// The statements and what they entail, indexed for lookups.
    private let index: TripleIndex

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
        // A subproperty's subjects and objects are its superproperty's
        // (rdfs7 with rdfs2 and rdfs3), so it has its domain and range:
        // OWL 2 RL scm-dom2 and scm-rng2.
        let inheritance = ["scm-dom2", "scm-rng2"].compactMap(semantics.rule(named:))
        let closure = Self.closure(of: axioms, under: semantics.rdfsEntailment + inheritance)
        index = closure

        let subClassOf = subClassOf
        let root = root
        let type = type
        universal = closure.subjects(subClassOf, root).filter { closure.contains(Triple(root, subClassOf, $0)) }.union([root])
        functional = Set(semantics.rule(named: "prp-fp").map { rule in
            rule.premises.lazy.filter { $0.predicate.iri == type }.compactMap(\.object.iri)
        } ?? [])
    }

    /// The statements closed under the rules whose premises and conclusions
    /// are all triple patterns, by semi-naive evaluation: each pass joins one
    /// premise of a rule with the triples the previous pass derived and the
    /// others with all triples, so no instantiation is found twice, until a
    /// pass derives nothing new.
    static func closure(of statements: [Triple], under rules: [EntailmentRule]) -> TripleIndex {
        let rules = rules.filter { !$0.isInconsistency && !$0.premises.isEmpty }
        var all = TripleIndex(statements)
        var delta = all
        while !delta.isEmpty {
            var derived = TripleIndex([])
            for rule in rules {
                for position in rule.premises.indices {
                    for binding in bindings(of: rule.premises, newAt: position, delta: delta, all: all) {
                        for conclusion in rule.conclusions {
                            guard let triple = instance(of: conclusion, under: binding), !all.contains(triple) else { continue }
                            derived.insert(triple)
                        }
                    }
                }
            }
            for triple in derived.triples { all.insert(triple) }
            delta = derived
        }
        return all
    }

    /// The bindings of the variables under which every premise is a triple,
    /// the one at `position` a new one. The premises are joined new premise
    /// first, then each time the one with the most terms bound, through the
    /// indexes.
    static func bindings(of premises: [TriplePattern], newAt position: Int, delta: TripleIndex, all: TripleIndex) -> [[String: String]] {
        var bindings: [[String: String]] = delta.candidates(for: premises[position], under: [:]).compactMap { match(premises[position], $0, [:]) }
        var remaining = premises.indices.filter { $0 != position }
        while !remaining.isEmpty, let sample = bindings.first {
            let next = remaining.max { boundTerms(premises[$0], sample) < boundTerms(premises[$1], sample) }!
            remaining.removeAll { $0 == next }
            let premise = premises[next]
            bindings = bindings.flatMap { binding in
                all.candidates(for: premise, under: binding).compactMap { match(premise, $0, binding) }
            }
        }
        return bindings
    }

    /// How many of a pattern's terms are IRIs or variables bound.
    private static func boundTerms(_ pattern: TriplePattern, _ binding: [String: String]) -> Int {
        [pattern.subject, pattern.predicate, pattern.object].count { term in
            if case .variable(let name) = term { return binding[name] != nil }
            return true
        }
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

    /// The objects of a term's statements of a predicate, entailed ones
    /// included: a subproperty's inherited domain and range.
    public func objects(of term: String, _ predicate: String) -> Set<String> {
        index.objects(term, predicate)
    }

    /// Of a set of classes, the most specific: the one that is a subclass
    /// of all the others.
    public func mostSpecific(of classes: [String]) -> String? {
        classes.first { candidate in classes.allSatisfy { isSubclass(candidate, of: $0) || $0 == candidate } } ?? classes.first
    }

    /// The classes a term is an instance of.
    public func types(of term: String) -> Set<String> {
        index.objects(term, type)
    }

    public func isSubclass(_ term: String, of superclass: String) -> Bool {
        index.contains(Triple(term, subClassOf, superclass))
    }

    /// Whether a term is an instance of a class.
    public func isInstance(_ term: String, of `class`: String) -> Bool {
        index.contains(Triple(term, type, `class`))
    }

    /// Whether a term is a class: an instance of the class of classes.
    public func isClass(_ term: String) -> Bool {
        isInstance(term, of: classOfClasses)
    }

    /// Whether a term is a property: an instance of the class of properties.
    public func isProperty(_ term: String) -> Bool {
        isInstance(term, of: classOfProperties)
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
        functional.contains { isInstance(property, of: $0) }
    }

    /// Whether a property is an annotation property, documentation (D8).
    public func isAnnotationProperty(_ property: String) -> Bool {
        classOfAnnotationProperties.map { isInstance(property, of: $0) } ?? false
    }
}

/// Triples indexed for the joins of a closure: by predicate, predicate and
/// subject, predicate and object, subject, and object; and their objects by
/// subject and predicate, and subjects by predicate and object, for lookups.
struct TripleIndex {
    private struct Key: Hashable {
        let first: String
        let second: String
    }

    private(set) var triples: [Schema.Triple] = []
    private(set) var set: Set<Schema.Triple> = []
    private var byPredicate: [String: [Schema.Triple]] = [:]
    private var byPredicateSubject: [Key: [Schema.Triple]] = [:]
    private var byPredicateObject: [Key: [Schema.Triple]] = [:]
    private var bySubject: [String: [Schema.Triple]] = [:]
    private var byObject: [String: [Schema.Triple]] = [:]
    private var objects: [Key: Set<String>] = [:]
    private var subjects: [Key: Set<String>] = [:]

    init(_ triples: [Schema.Triple]) {
        for triple in triples { insert(triple) }
    }

    var isEmpty: Bool { triples.isEmpty }

    func contains(_ triple: Schema.Triple) -> Bool { set.contains(triple) }

    mutating func insert(_ triple: Schema.Triple) {
        guard set.insert(triple).inserted else { return }
        triples.append(triple)
        byPredicate[triple.predicate, default: []].append(triple)
        byPredicateSubject[Key(first: triple.predicate, second: triple.subject), default: []].append(triple)
        byPredicateObject[Key(first: triple.predicate, second: triple.object), default: []].append(triple)
        bySubject[triple.subject, default: []].append(triple)
        byObject[triple.object, default: []].append(triple)
        objects[Key(first: triple.subject, second: triple.predicate), default: []].insert(triple.object)
        subjects[Key(first: triple.predicate, second: triple.object), default: []].insert(triple.subject)
    }

    /// The objects of a subject's triples of a predicate.
    func objects(_ subject: String, _ predicate: String) -> Set<String> {
        objects[Key(first: subject, second: predicate)] ?? []
    }

    /// The subjects of the triples of a predicate and an object.
    func subjects(_ predicate: String, _ object: String) -> Set<String> {
        subjects[Key(first: predicate, second: object)] ?? []
    }

    /// The triples a pattern can match under a binding, through the most
    /// selective index its bound terms allow.
    func candidates(for pattern: TriplePattern, under binding: [String: String]) -> [Schema.Triple] {
        func value(_ term: PatternTerm) -> String? {
            switch term {
            case .iri(let iri): iri
            case .variable(let name): binding[name]
            }
        }
        let subject = value(pattern.subject)
        let predicate = value(pattern.predicate)
        let object = value(pattern.object)
        switch (subject, predicate, object) {
        case (let subject?, let predicate?, _): return byPredicateSubject[Key(first: predicate, second: subject)] ?? []
        case (_, let predicate?, let object?): return byPredicateObject[Key(first: predicate, second: object)] ?? []
        case (_, let predicate?, nil): return byPredicate[predicate] ?? []
        case (let subject?, nil, _): return bySubject[subject] ?? []
        case (nil, nil, let object?): return byObject[object] ?? []
        case (nil, nil, nil): return triples
        }
    }
}
