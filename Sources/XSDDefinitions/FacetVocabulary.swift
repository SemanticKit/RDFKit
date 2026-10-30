/// The constraining facets the XML representation of a simple type
/// definition can use, as the schema for schema documents declares them
/// (XML Schema 1.1 Part 2 Appendix A, `datatypes.xsd`): each element in the
/// substitution group of `xs:facet`, and the kind of value it takes.
public struct FacetVocabulary: Sendable {
    /// How a facet's `value` attribute is written.
    public enum Kind: Equatable, Sendable {
        /// A nonnegative integer: the facet's type is `xs:numFacet`.
        case number
        /// One of the keywords its `value` attribute enumerates
        /// (`whiteSpace`: `preserve`, `replace`, `collapse`).
        case keyword([String])
        /// A facet that cannot be fixed, `xs:noFixedFacet`, of which a
        /// derivation step may give several, any of which the value satisfies
        /// (`pattern`, §4.3.4; `enumeration`, §4.3.5).
        case alternatives
        /// A literal of the datatype being restricted (`minInclusive`).
        case literal
        /// An XPath assertion, which this translation has no Swift for.
        case assertion
    }

    /// The XML Schema namespace, the schema's `targetNamespace`.
    public let namespace: String

    /// The facets, by element name.
    public let facets: [String: Kind]

    public init(schema: SchemaElement) throws {
        guard let namespace = schema.attributes["targetNamespace"] else {
            throw DefinitionError(description: "the schema for schema documents names no targetNamespace")
        }
        var facets: [String: Kind] = [:]
        for element in schema.children("element", in: namespace) {
            guard let group = element.attributes["substitutionGroup"], let name = element.attributes["name"],
                  try element.resolve(qualifiedName: group) == (namespace, "facet") else { continue }
            facets[name] = try Self.kind(of: element, namespace: namespace)
        }
        guard !facets.isEmpty else { throw DefinitionError(description: "the schema for schema documents declares no facets") }
        self.namespace = namespace
        self.facets = facets
    }

    /// The kind of a facet element: by its `type`, or by the base of the
    /// complex type it declares and the values it allows for `value`.
    private static func kind(of element: SchemaElement, namespace: String) throws -> Kind {
        var base = try element.attributes["type"].map { try element.resolve(qualifiedName: $0).localName }
        var keywords: [String] = []
        for complexType in element.children("complexType", in: namespace) {
            for content in complexType.children("complexContent", in: namespace) {
                for restriction in content.children("restriction", in: namespace) {
                    base = try restriction.attributes["base"].map { try restriction.resolve(qualifiedName: $0).localName }
                    for attribute in restriction.children("attribute", in: namespace) where attribute.attributes["name"] == "value" {
                        for simpleType in attribute.children("simpleType", in: namespace) {
                            for valueRestriction in simpleType.children("restriction", in: namespace) {
                                keywords += valueRestriction.children("enumeration", in: namespace).compactMap { $0.attributes["value"] }
                            }
                        }
                    }
                }
            }
        }
        if !keywords.isEmpty { return .keyword(keywords) }
        switch base {
        case "numFacet", "intFacet": return .number
        case "noFixedFacet": return .alternatives
        case "assertion": return .assertion
        default: return .literal
        }
    }
}
