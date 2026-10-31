/// What the schema of the ontologies a declaration is generated with says
/// about their terms, by the terms' Swift names (`RDFS.Resource`).
public struct SwiftSchema: Sendable {
    /// The root (D7).
    public var root: String?
    /// The classes that are another class, by what they are: the classes
    /// equal to the root are the root, and the empty classes are `Never`
    /// (D7).
    public var aliases: [String: String]
    /// The classes whose members are literal values (D6).
    public var literalClasses: Set<String>
    /// The classes whose members are classes or properties (D4).
    public var typeDescribingClasses: Set<String>
    /// The classes of the properties that have at most one value (D5).
    public var functionalClasses: Set<String>
    /// The property whose values are an individual's classes, its
    /// conformances (D2).
    public var typeProperty: String?

    public init(root: String? = nil, aliases: [String: String] = [:], literalClasses: Set<String> = [], typeDescribingClasses: Set<String> = [], functionalClasses: Set<String> = [], typeProperty: String? = nil) {
        self.root = root
        self.aliases = aliases
        self.literalClasses = literalClasses
        self.typeDescribingClasses = typeDescribingClasses
        self.functionalClasses = functionalClasses
        self.typeProperty = typeProperty
    }

    /// A schema's terms by their Swift names; `swiftName` names a term's IRI
    /// as the Swift type that declares it.
    public init(_ schema: Schema, terms: [String], swiftName: (String) -> String?) {
        let root = swiftName(schema.root)
        var aliases: [String: String] = [:]
        if let root {
            for term in schema.universal where term != schema.root {
                if let name = swiftName(term) { aliases[name] = root }
            }
        }
        for term in schema.empty {
            if let name = swiftName(term) { aliases[name] = "Never" }
        }
        self.init(
            root: root,
            aliases: aliases,
            literalClasses: Set(terms.filter(schema.isLiteralClass).compactMap(swiftName)),
            typeDescribingClasses: Set(terms.filter(schema.describesTypes).compactMap(swiftName)),
            functionalClasses: Set(schema.functional.compactMap(swiftName)),
            typeProperty: swiftName(schema.type)
        )
    }
}
