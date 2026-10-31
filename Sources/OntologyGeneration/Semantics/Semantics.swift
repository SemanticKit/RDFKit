/// What the W3C specifications say the RDF, RDFS and OWL terms mean, read
/// from their own tables by SemanticsEmitter on every build
/// (`Sources/OntologyGeneration/W3C`):
///
/// - the RDFS entailment patterns of RDF 1.2 Semantics (rdfs2 to rdfs13),
/// - the OWL 2 RL rules of OWL 2 Profiles §4.3 (prp-fp, cls-nothing2, …),
/// - the parts of the universe and the conditions on the class extensions
///   of the built-in classes of OWL 2 RDF-Based Semantics §4.1 and §5.2
///   (`owl:Thing ∈ IC, = IR`), the D7 semantics,
/// - and the prefixes those tables are written with.
public struct Semantics: Sendable {
    public let rdfsEntailment: [EntailmentRule]
    public let owl2RL: [EntailmentRule]
    public let classExtensions: [ClassExtension]
    public let propertyExtensions: [PropertyExtension]
    public let parts: [UniversePart]
    public let prefixes: [NamespacePrefix]

    public init(rdfsEntailment: [EntailmentRule], owl2RL: [EntailmentRule], classExtensions: [ClassExtension], propertyExtensions: [PropertyExtension], parts: [UniversePart], prefixes: [NamespacePrefix]) {
        self.rdfsEntailment = rdfsEntailment
        self.owl2RL = owl2RL
        self.classExtensions = classExtensions
        self.propertyExtensions = propertyExtensions
        self.parts = parts
        self.prefixes = prefixes
    }

    /// A rule of either table, by the name its specification gives it.
    public func rule(named name: String) -> EntailmentRule? {
        (rdfsEntailment + owl2RL).first { $0.name == name }
    }
}

/// A term of a triple pattern: an IRI, or a variable (`xxx`, `?p`).
public enum PatternTerm: Hashable, Sendable {
    case iri(String)
    case variable(String)

    public var iri: String? {
        if case .iri(let iri) = self { return iri }
        return nil
    }
}

/// A triple pattern of a rule: `xxx rdfs:subClassOf yyy .`.
public struct TriplePattern: Hashable, Sendable {
    public let subject: PatternTerm
    public let predicate: PatternTerm
    public let object: PatternTerm

    public init(_ subject: PatternTerm, _ predicate: PatternTerm, _ object: PatternTerm) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
    }
}

/// An entailment rule: when a graph contains the premises, it entails the
/// conclusions. A rule whose conclusion is `false`, such as cls-nothing2,
/// says the premises are inconsistent.
public struct EntailmentRule: Sendable {
    public let name: String
    public let premises: [TriplePattern]
    public let conclusions: [TriplePattern]
    public let isInconsistency: Bool

    public init(name: String, premises: [TriplePattern], conclusions: [TriplePattern], isInconsistency: Bool) {
        self.name = name
        self.premises = premises
        self.conclusions = conclusions
        self.isInconsistency = isInconsistency
    }
}

/// A condition on the class extension of a built-in class (OWL 2
/// RDF-Based Semantics §5.2): `owl:Thing ∈ IC, = IR` is
/// `ClassExtension(class: owl:Thing, isEqual: true, part: "IR")`. The part
/// `∅` is the empty set.
public struct ClassExtension: Sendable {
    public let `class`: String
    public let isEqual: Bool
    public let part: String

    public init(class: String, isEqual: Bool, part: String) {
        self.class = `class`
        self.isEqual = isEqual
        self.part = part
    }
}

/// The part of the universe a built-in property belongs to (OWL 2
/// RDF-Based Semantics §5.3): `rdfs:label ∈ IOAP`.
public struct PropertyExtension: Sendable {
    public let property: String
    public let part: String

    public init(property: String, part: String) {
        self.property = property
        self.part = part
    }
}

/// A part of the universe (OWL 2 RDF-Based Semantics §4.1), the parts it is
/// a subset of, and the class whose extension it is, when the
/// specification names one (`IR`, `rdfs:Resource`).
public struct UniversePart: Sendable {
    public let name: String
    public let supersets: [String]
    public let `class`: String?

    public init(name: String, supersets: [String], class: String?) {
        self.name = name
        self.supersets = supersets
        self.class = `class`
    }
}

/// A namespace prefix the specifications' tables are written with.
public struct NamespacePrefix: Sendable {
    public let prefix: String
    public let namespace: String

    public init(_ prefix: String, _ namespace: String) {
        self.prefix = prefix
        self.namespace = namespace
    }
}
