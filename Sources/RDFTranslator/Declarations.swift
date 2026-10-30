/// The Swift one module declares for the resources its documents name.
///
/// - A class (an instance of `rdfs:Class`, stated or entailed) is two Swift
///   declarations: a protocol, for membership, which refines the protocols
///   of its superclasses, and a final class whose instances are its members
///   and whose stored properties are the properties they have. FOAF's
///   `foaf:Person` is the protocol `Person` and the class `PersonIndividual`.
/// - Any other resource is an individual: one instance of the class of the
///   class its documents state it is a member of. An individual that is a
///   member of several classes, or of none, is an instance of a class
///   generated for that combination, which conforms to the protocol of each.
/// - Each property is a stored property of the classes of the things that
///   have it, typed by its range, and a requirement of the protocol of its
///   domain when this module declares both.
///
/// Every IRI has one declaration, in the lowest module whose documents
/// describe it (name it as a subject); higher modules refer to it. A
/// resource a module only names in object or predicate position, without
/// describing it, is declared privately in that module.
///
/// A described resource is public, named by its local name. Two resources
/// with one local name keep the name for the one the documents say a
/// vocabulary defines: `rdfs:isDefinedBy` "is used to indicate a resource
/// defining the subject resource" (RDF 1.2 Schema, rdfs:isDefinedBy). FOAF
/// describes `dc:title` and defines `foaf:title`, so `title` is
/// `foaf:title`. Between two resources both defined, or both not, the first
/// in document order keeps the name. The other is private, reachable through
/// the module's `ontology`.
struct Declarations {
    var module: String

    /// The classes this module declares.
    var classes: [NodeID: ClassDeclaration] = [:]

    /// The individuals this module declares.
    var individuals: [NodeID: IndividualDeclaration] = [:]

    /// Every node this module declares, in document order.
    var order: [NodeID] = []

    /// The protocols each declared class's protocol refines.
    var refinements: [NodeID: [NodeID]] = [:]

    /// The requirements of each declared class's protocol.
    var requirements: [NodeID: [Member]] = [:]

    /// The classes generated for individuals that are members of several
    /// classes, or of none.
    var combinations: [Combination] = []

    /// The resources a lower module declares that this module's documents
    /// describe.
    var additions: [NodeID] = []

    /// The properties declared here or below that a member of this module
    /// can have, nearest module first.
    var properties: [NodeID] = []

    /// Names that generated code declares in every module.
    static let reserved: Set<String> = ["ontology", "described"]

    /// Names a generated class declares itself.
    static let memberNames: Set<String> = ["iri", "storage", "encode", "encodeDescription", "init", "Values"]

    init(_ layer: Layer, _ vocabulary: Vocabulary, below: [Declarations]) throws {
        module = layer.module
        let lower = Lower(below)

        // The nodes this module declares: every node its documents name that
        // no lower module declares publicly.
        let subjects = Set(layer.statements.map(\.subject))
        var seen: Set<NodeID> = []
        for statement in layer.statements {
            let nodes = [statement.subject, .iri(statement.predicate)] + [statement.object.node].compactMap(\.self)
            for node in nodes where seen.insert(node).inserted {
                if !lower.declares(node) {
                    order.append(node)
                } else if subjects.contains(node) {
                    additions.append(node)
                }
            }
        }

        // Names. Resources the documents say a vocabulary defines take their
        // names before resources the documents only describe.
        let defined = Set(layer.statements.filter { $0.predicate == Term.isDefinedBy }.map(\.subject))
        let described = order.filter { subjects.contains($0) && $0.iri != nil }
        let byPrecedence = described.filter(defined.contains) + described.filter { !defined.contains($0) }
        var taken = Self.reserved
        var names: [NodeID: String] = [:]
        for node in byPrecedence {
            let name = SwiftName.localName(of: node.iri!)
            guard SwiftName.isUsable(name), !taken.contains(name) else { continue }
            if vocabulary.isClass(node) {
                let className = name + "Individual"
                guard !taken.contains(className) else { continue }
                taken.insert(className)
            }
            taken.insert(name)
            names[node] = name
        }
        for (index, node) in order.enumerated() {
            let handle = "resource \(index)"
            if vocabulary.isClass(node) {
                let name = names[node]
                classes[node] = ClassDeclaration(
                    node: node, module: module, isPublic: name != nil,
                    protocolName: name ?? handle, className: name.map { $0 + "Individual" } ?? handle + " Individual"
                )
            } else {
                individuals[node] = IndividualDeclaration(node: node, module: module, isPublic: names[node] != nil, name: names[node] ?? handle)
            }
        }

        refine(vocabulary, lower: lower)

        // The properties a member of this module can have: those this module
        // declares, then the public ones of the modules below.
        properties = order.filter { individuals[$0] != nil && vocabulary.isProperty($0) && $0 != .iri(Term.type) }
        for declarations in below.reversed() {
            properties += declarations.properties.filter { declarations.individuals[$0]?.isPublic == true && !properties.contains($0) }
        }

        var planner = Planner(declarations: self, lower: lower, vocabulary: vocabulary, layer: layer)
        try planner.plan()
        self = planner.declarations
    }

    /// A class's protocol refines the protocols of the classes it is a
    /// subclass of (rdfs9). Swift protocols cannot refine each other in a
    /// cycle, so of classes that are subclasses of each other the later one
    /// refines the earlier. A public protocol refines only public ones.
    private mutating func refine(_ vocabulary: Vocabulary, lower: Lower) {
        let position = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        for (index, node) in order.enumerated() {
            guard let declaration = classes[node] else { continue }
            let superclasses = vocabulary.superclassClosure(of: node).filter { superclass in
                guard superclass != node else { return false }
                if let other = lower.class(superclass) { return other.isPublic || !declaration.isPublic }
                guard let other = classes[superclass], let otherIndex = position[superclass] else { return false }
                guard other.isPublic || !declaration.isPublic else { return false }
                let mutual = vocabulary.superclassClosure(of: superclass).contains(node)
                return !mutual || otherIndex < index
            }
            // A protocol another one already refines is left out.
            refinements[node] = superclasses.filter { superclass in
                !superclasses.contains { other in
                    guard other != superclass else { return false }
                    if lower.class(other) != nil {
                        return lower.refinementClosure(of: other).contains(superclass)
                    }
                    return vocabulary.superclassClosure(of: other).contains(superclass)
                        && !vocabulary.superclassClosure(of: superclass).contains(other)
                }
            }.sorted { ($0.iri ?? "") < ($1.iri ?? "") }
        }
    }

    // MARK: - Lookups across modules

    /// The class declaration of `node`, in this module or, when public, in
    /// one below.
    func `class`(_ node: NodeID, below: [Declarations]) -> ClassDeclaration? {
        classes[node] ?? Lower(below).class(node)
    }
}

/// The class of an RDF class: its protocol and the Swift class of its
/// members.
struct ClassDeclaration {
    let node: NodeID
    var module: String
    let isPublic: Bool
    let protocolName: String
    let className: String

    /// The members of the class's instances.
    var members: [Member] = []

    /// The protocols the class conforms to, without those another implies.
    var conformances: [NodeID] = []

    /// The protocol, as Swift refers to it from any module.
    var protocolReference: String {
        isPublic ? "\(module).\(SwiftName.identifier(protocolName))" : SwiftName.identifier(protocolName)
    }

    /// The class, as Swift refers to it from any module.
    var classReference: String {
        isPublic ? "\(module).\(SwiftName.identifier(className))" : SwiftName.identifier(className)
    }
}

/// An individual: its name and the class it is an instance of.
struct IndividualDeclaration {
    let node: NodeID
    var module: String
    let isPublic: Bool
    let name: String

    /// The Swift class of the individual.
    var instanceOf: InstanceClass = .combination(0)

    /// The protocols the individual conforms to, with those they refine.
    var conformances: Set<NodeID> = []

    /// The Swift type of the public constant.
    var publicType = "any RDFRuntime.Resource"

    /// The individual, as Swift refers to it from any module.
    var reference: String {
        isPublic ? "\(module).\(SwiftName.identifier(name))" : SwiftName.identifier(name)
    }
}

/// The Swift class an individual is an instance of.
enum InstanceClass: Hashable {
    /// The class of an RDF class, in this module or one below.
    case `class`(NodeID)
    /// A class generated in this module for a combination of classes.
    case combination(Int)
}

/// A class generated for the individuals that are members of a combination
/// of classes: those the documents state (written back as `rdf:type`) and
/// those entailed.
struct Combination {
    let name: String
    /// The classes the documents state, in IRI order.
    let stated: [NodeID]
    /// The protocols the class conforms to, without those another implies.
    let conformances: [NodeID]
    var members: [Member]
}

/// A stored property of a generated class: the property and the Swift type
/// of its values.
struct Member {
    let property: NodeID
    var name: String
    var kind: ValueKind
    /// Whether the member is a protocol requirement, whose name and type are
    /// fixed.
    var isRequirement = false
}

/// The Swift type of a property's values.
enum ValueKind: Hashable {
    /// `[RDFCore.Literal]`: the range is a literal class or datatype.
    case literals
    /// `[any RDFRuntime.Class.Type]`: the range is a class of classes.
    case classes
    /// `[any A & B]`: the range is classes of individuals.
    case individuals([NodeID])
    /// `[RDFRuntime.Value]`: the range admits any resource.
    case values
}

/// The public declarations of the modules below one module.
struct Lower {
    let modules: [Declarations]

    init(_ modules: [Declarations]) {
        self.modules = modules
    }

    func declares(_ node: NodeID) -> Bool {
        `class`(node) != nil || individual(node) != nil
    }

    func `class`(_ node: NodeID) -> ClassDeclaration? {
        for module in modules {
            if let declaration = module.classes[node], declaration.isPublic { return declaration }
        }
        return nil
    }

    func individual(_ node: NodeID) -> IndividualDeclaration? {
        for module in modules {
            if let declaration = module.individuals[node], declaration.isPublic { return declaration }
        }
        return nil
    }

    func requirements(of node: NodeID) -> [Member] {
        for module in modules {
            if let members = module.requirements[node] { return members }
        }
        return []
    }

    /// Every protocol the protocol of `node` refines, through the refinements
    /// of these modules.
    func refinementClosure(of node: NodeID, local: [NodeID: [NodeID]] = [:]) -> Set<NodeID> {
        var closure: Set<NodeID> = []
        var pending = [node]
        while let next = pending.popLast() {
            for refined in modules.flatMap({ $0.refinements[next] ?? [] }) + (local[next] ?? []) where closure.insert(refined).inserted {
                pending.append(refined)
            }
        }
        return closure
    }
}

/// Spelling Swift identifiers for RDF names.
enum SwiftName {
    /// The local name of an IRI: what follows its last `#`, or else its
    /// last `/`.
    static func localName(of iri: String) -> String {
        if let hash = iri.lastIndex(of: "#") { return String(iri[iri.index(after: hash)...]) }
        if let slash = iri.lastIndex(of: "/") { return String(iri[iri.index(after: slash)...]) }
        return ""
    }

    /// Whether a local name can be a raw identifier (SE-0451, Permitted
    /// characters): it is not empty, not only whitespace or operator
    /// characters, and has no backtick, backslash or control character.
    static func isUsable(_ name: String) -> Bool {
        guard !name.isEmpty,
              !name.unicodeScalars.allSatisfy(\.properties.isWhitespace),
              !name.allSatisfy({ "/=-+!*%<>&|^~?.".contains($0) }) else { return false }
        return !name.unicodeScalars.contains { $0 == "`" || $0 == "\\" || $0.value < 0x20 || $0.value == 0x7F }
    }

    /// The identifier, always in backticks, so keywords and names Swift's
    /// identifier grammar does not allow are raw identifiers (SE-0451).
    static func identifier(_ name: String) -> String {
        "`" + name + "`"
    }

    /// A Swift string literal of `text`.
    static func stringLiteral(_ text: String) -> String {
        var literal = "\""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "\"": literal += "\\\""
            case "\\": literal += "\\\\"
            case "\n": literal += "\\n"
            case "\r": literal += "\\r"
            case "\t": literal += "\\t"
            case "\u{00}"..."\u{1F}", "\u{7F}": literal += "\\u{\(String(scalar.value, radix: 16))}"
            default: literal.unicodeScalars.append(scalar)
            }
        }
        return literal + "\""
    }
}
