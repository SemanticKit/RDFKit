import IRIKit
import RDFCore

/// The Swift one module declares for the resources its documents name.
///
/// - A class (an instance of `rdfs:Class`, stated or entailed) is a
///   protocol, for membership, which refines the protocols of its
///   superclasses; a storing protocol, which gives a member of the class
///   every property it can have; and a final class whose instances are its
///   members. FOAF's `foaf:Person` is the protocol `Person`, the storing
///   protocol `PersonStoring` and the class `PersonIndividual`.
/// - A property is an individual of `rdf:Property`, and is also a
///   ``RDFCore/PropertyValue`` type that holds its values on an individual
///   (`knowsValue`) and a storing protocol that gives it its accessor
///   (`knowsStoring`), typed by its range.
/// - Any other resource is an individual: one instance of the class of the
///   class its documents state it is a member of. An individual that is a
///   member of several classes, or of none, or that has a property its
///   class's members cannot have, is an instance of a class generated for
///   that combination, which conforms to the storing protocol of each.
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
///
/// A property's accessor on an individual is named by its local name. An
/// individual of this module can conform to the storing protocols of every
/// module below, and a Swift type has one member of a name: SHACL's
/// `sh:value` cannot be `value` on an `sh:ValidationResult`, which is an
/// `RDF.Resource` and so already has `rdf:value` as `value`. When a module
/// below already names an accessor by the property's local name, the
/// property's accessor is named by its module and its local name in lower
/// camel case, as the Swift API Design Guidelines spell a compound name
/// ("Follow case conventions"): `sh:value` is `shaclValue`, and `rdf:value`
/// stays `value`.
struct Declarations {
    var module: String

    /// The classes this module declares.
    var classes: [SubjectTerm: ClassDeclaration] = [:]

    /// The individuals this module declares.
    var individuals: [SubjectTerm: IndividualDeclaration] = [:]

    /// The properties this module declares: individuals that are properties.
    var properties: [SubjectTerm: PropertyDeclaration] = [:]

    /// Every node this module declares, in document order.
    var order: [SubjectTerm] = []

    /// The protocols each declared class's protocol refines.
    var refinements: [SubjectTerm: [SubjectTerm]] = [:]

    /// The requirements of each declared class's protocol.
    var requirements: [SubjectTerm: [SubjectTerm]] = [:]

    /// The classes generated for individuals that are members of several
    /// classes, or of none.
    var combinations: [Combination] = []

    /// The resources a lower module declares that this module's documents
    /// describe.
    var additions: [SubjectTerm] = []

    /// Names that generated code declares in every module.
    static let reserved: Set<String> = ["ontology", "described"]

    /// Names a generated class declares itself.
    static let memberNames: Set<String> = ["iri", "storage", "encode", "encodeDescription", "init", "Member", "classes"]

    init(_ layer: Layer, _ vocabulary: Vocabulary, below: [Declarations]) throws {
        module = layer.module
        let lower = Lower(below)

        // The nodes this module declares: every node its documents name that
        // no lower module declares publicly.
        let subjects = Set(layer.graph.map(\.subject))
        var seen: Set<SubjectTerm> = []
        for triple in layer.graph {
            let nodes = [triple.subject, .iri(triple.predicate)] + [triple.object.node].compactMap(\.self)
            for node in nodes where seen.insert(node).inserted {
                if !lower.declares(node) {
                    order.append(node)
                } else if subjects.contains(node) {
                    additions.append(node)
                }
            }
        }

        // Names. Resources the documents say a vocabulary defines take their
        // names before resources the documents only describe. A class also
        // takes the names of its storing protocol and its Swift class, and a
        // property the names of its value type and storing protocol.
        let defined = Set(layer.graph.filter { $0.predicate == .rdfsIsDefinedBy }.map(\.subject))
        let described = order.filter { subjects.contains($0) && $0.iri != nil }
        let byPrecedence = described.filter(defined.contains) + described.filter { !defined.contains($0) }
        var taken = Self.reserved
        var names: [SubjectTerm: String] = [:]
        for node in byPrecedence {
            let name = node.iri!.localName
            guard name.isUsableAsIdentifier, !taken.contains(name) else { continue }
            let derived = vocabulary.isClass(node) ? [name + "Individual", name + "Storing"]
                : vocabulary.isProperty(node) ? [name + "Value", name + "Storing"] : []
            guard derived.allSatisfy({ !taken.contains($0) }) else { continue }
            taken.formUnion(derived + [name])
            names[node] = name
        }
        let lowerMembers = lower.members
        for (index, node) in order.enumerated() {
            let handle = "resource \(index)"
            let name = names[node]
            if vocabulary.isClass(node) {
                classes[node] = ClassDeclaration(node: node, module: module, isPublic: name != nil, name: name ?? handle)
            } else {
                individuals[node] = IndividualDeclaration(node: node, module: module, isPublic: name != nil, name: name ?? handle)
                if vocabulary.isProperty(node) {
                    // A private property's member is named by its local name
                    // where Swift can spell it; only the private classes
                    // that store it have it.
                    var member = name ?? handle
                    if name == nil, let iri = node.iri, case let local = iri.localName, local.isUsableAsIdentifier {
                        member = local
                    }
                    if Self.memberNames.contains(member) { member += "_" }
                    if lowerMembers.contains(member) {
                        member = module.lowerCamelCasePrefix + member.capitalizingFirstLetter
                    }
                    properties[node] = PropertyDeclaration(node: node, module: module, isPublic: name != nil, name: name ?? handle, member: member)
                }
            }
        }

        refine(vocabulary, lower: lower)
        separateMembers()

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
            }.sorted(by: SubjectTerm.inIRIOrder)
        }
    }

    /// Gives each property of this module an accessor of its own name. A
    /// private property's accessor is named by its local name, and two
    /// properties can have one: the entailment regime documents state both
    /// `dc:title` and `foaf:title`, and neither has a domain there, so every
    /// individual has both, and a Swift type has one member of a name. A
    /// public property keeps its name; of private ones, the first in
    /// document order keeps it, and the others are named by their handle.
    private mutating func separateMembers() {
        let properties = order.compactMap { self.properties[$0] }
        var taken = Set(properties.filter(\.isPublic).map(\.member))
        for property in properties where !property.isPublic {
            if taken.insert(property.member).inserted { continue }
            self.properties[property.node] = PropertyDeclaration(node: property.node, module: module, isPublic: false, name: property.name, member: property.name)
        }
    }
}

/// The Swift of an RDF class: its protocol, storing protocol and the Swift
/// class of its members.
struct ClassDeclaration {
    let node: SubjectTerm
    var module: String
    let isPublic: Bool
    let name: String

    /// The protocols the class conforms to, without those another implies.
    var conformances: [SubjectTerm] = []

    /// The storing protocols the class's storing protocol refines: those of
    /// the classes it conforms to and of the properties its members can
    /// have that this module declares.
    var storing: [Storing] = []

    /// The properties a member of the class has an accessor for.
    var stored: Set<SubjectTerm> = []

    /// The Swift type of a member of the class as a property value.
    var member: ValueKind = .values

    var protocolName: String { name }
    var className: String { isPublic ? name + "Individual" : name + " Individual" }
    var storingName: String { isPublic ? name + "Storing" : name + " Storing" }

    /// The protocol, as Swift refers to it from any module.
    var protocolReference: String { reference(protocolName) }

    /// The class, as Swift refers to it from any module.
    var classReference: String { reference(className) }

    /// The storing protocol, as Swift refers to it from any module.
    var storingReference: String { reference(storingName) }

    private func reference(_ name: String) -> String {
        isPublic ? "\(module)::\(name.swiftIdentifier)" : name.swiftIdentifier
    }
}

/// A property: its value type and storing protocol, and the Swift type of
/// its values.
struct PropertyDeclaration {
    let node: SubjectTerm
    var module: String
    let isPublic: Bool
    let name: String

    /// The name of the property's accessor on an individual.
    let member: String

    /// The Swift type of the property's values.
    var kind: ValueKind = .values

    var valueName: String { isPublic ? name + "Value" : name + " Value" }
    var storingName: String { isPublic ? name + "Storing" : name + " Storing" }

    var valueReference: String { reference(valueName) }
    var storingReference: String { reference(storingName) }

    private func reference(_ name: String) -> String {
        isPublic ? "\(module)::\(name.swiftIdentifier)" : name.swiftIdentifier
    }
}

/// A storing protocol a class or a combination conforms to.
enum Storing: Hashable {
    /// The storing protocol of a class.
    case `class`(SubjectTerm)
    /// The storing protocol of a property.
    case property(SubjectTerm)
}

/// An individual: its name and the class it is an instance of.
struct IndividualDeclaration {
    let node: SubjectTerm
    var module: String
    let isPublic: Bool
    let name: String

    /// The Swift class of the individual.
    var instanceOf: InstanceClass = .combination(0)

    /// The protocols the individual conforms to, with those they refine.
    var conformances: Set<SubjectTerm> = []

    /// The Swift type of the public constant.
    var publicType = "any RDFCore::Resource"

    /// The individual, as Swift refers to it from any module.
    var reference: String {
        isPublic ? "\(module)::\(name.swiftIdentifier)" : name.swiftIdentifier
    }
}

/// The Swift class an individual is an instance of.
enum InstanceClass: Hashable {
    /// The class of an RDF class, in this module or one below.
    case `class`(SubjectTerm)
    /// A class generated in this module for a combination of classes.
    case combination(Int)
}

/// A class generated for the individuals that are members of a combination
/// of classes: those the documents state (written back as `rdf:type`) and
/// those entailed, with the properties they have.
struct Combination {
    let name: String
    /// The classes the documents state, in IRI order.
    let stated: [SubjectTerm]
    /// The protocols the class conforms to, without those another implies.
    let conformances: [SubjectTerm]
    /// The storing protocols it conforms to.
    var storing: [Storing]
}

/// The Swift type of a property's values.
enum ValueKind: Hashable {
    /// `[RDFCore::Literal]`: the range is a literal class or datatype.
    case literals
    /// `[any RDFCore::ResourceClass.Type]`: the range is a class of classes.
    case classes
    /// `[any A & B]`: the range is classes of individuals.
    case individuals([SubjectTerm])
    /// `[RDFCore::Value]`: the range admits any resource.
    case values
}

/// The public declarations of the modules below one module.
struct Lower {
    let modules: [Declarations]

    init(_ modules: [Declarations]) {
        self.modules = modules
    }

    func declares(_ node: SubjectTerm) -> Bool {
        `class`(node) != nil || individual(node) != nil
    }

    func `class`(_ node: SubjectTerm) -> ClassDeclaration? {
        for module in modules {
            if let declaration = module.classes[node], declaration.isPublic { return declaration }
        }
        return nil
    }

    func individual(_ node: SubjectTerm) -> IndividualDeclaration? {
        for module in modules {
            if let declaration = module.individuals[node], declaration.isPublic { return declaration }
        }
        return nil
    }

    func property(_ node: SubjectTerm) -> PropertyDeclaration? {
        for module in modules {
            if let declaration = module.properties[node], declaration.isPublic { return declaration }
        }
        return nil
    }

    /// The names of the accessors these modules give individuals: those of
    /// their public properties.
    var members: Set<String> {
        Set(modules.flatMap { $0.properties.values.filter(\.isPublic).map(\.member) })
    }

    func requirements(of node: SubjectTerm) -> [SubjectTerm] {
        for module in modules {
            if let members = module.requirements[node] { return members }
        }
        return []
    }

    /// Every protocol the protocol of `node` refines, through the refinements
    /// of these modules.
    func refinementClosure(of node: SubjectTerm, local: [SubjectTerm: [SubjectTerm]] = [:]) -> Set<SubjectTerm> {
        var closure: Set<SubjectTerm> = []
        var pending = [node]
        while let next = pending.popLast() {
            for refined in modules.flatMap({ $0.refinements[next] ?? [] }) + (local[next] ?? []) where closure.insert(refined).inserted {
                pending.append(refined)
            }
        }
        return closure
    }
}

extension IRI {
    /// The local name of the IRI: what follows its last `#`, or else its
    /// last `/`.
    var localName: String {
        if let hash = rawValue.lastIndex(of: "#") { return String(rawValue[rawValue.index(after: hash)...]) }
        if let slash = rawValue.lastIndex(of: "/") { return String(rawValue[rawValue.index(after: slash)...]) }
        return ""
    }
}

/// Spelling RDF names as Swift identifiers and string literals.
extension String {
    /// Whether the name can be a raw identifier (SE-0451, Permitted
    /// characters): it is not empty, not only whitespace or operator
    /// characters, and has no backtick, backslash or control character.
    var isUsableAsIdentifier: Bool {
        guard !isEmpty,
              !unicodeScalars.allSatisfy(\.properties.isWhitespace),
              !allSatisfy({ "/=-+!*%<>&|^~?.".contains($0) }) else { return false }
        return !unicodeScalars.contains { $0 == "`" || $0 == "\\" || $0.value < 0x20 || $0.value == 0x7F }
    }

    /// A module name as the first word of a lower camel case name: its
    /// leading capitals lowercased, an initialism all together and the
    /// capital that starts the next word kept (`SHACL` is `shacl`,
    /// `RDFTranslatorTests` is `rdfTranslatorTests`), as the Swift API Design
    /// Guidelines case initialisms.
    var lowerCamelCasePrefix: String {
        let capitals = prefix(while: \.isUppercase)
        guard !capitals.isEmpty else { return self }
        let rest = self[capitals.endIndex...]
        let lowered = capitals.count > 1 && rest.first?.isLowercase == true ? capitals.dropLast() : capitals
        return lowered.lowercased() + self[lowered.endIndex...]
    }

    /// The name with its first letter capitalized, as a later word of a
    /// lower camel case name.
    var capitalizingFirstLetter: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }

    /// The name as an identifier, always in backticks, so keywords and names Swift's
    /// identifier grammar does not allow are raw identifiers (SE-0451).
    var swiftIdentifier: String {
        "`" + self + "`"
    }

    /// A Swift string literal of the text.
    var swiftStringLiteral: String {
        var literal = "\""
        for scalar in unicodeScalars {
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
