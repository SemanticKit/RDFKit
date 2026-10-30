/// A top-level simple type definition of a schema document: the
/// illustrative XML representations of the built-in datatypes (XML Schema
/// 1.1 Part 2 Appendix C, `primitives.nxsd` and `derived.nxsd`).
public struct SimpleTypeDefinition: Sendable {
    /// A facet as the definition gives it.
    public struct GivenFacet: Sendable {
        public let name: String
        public let value: String
    }

    public let name: String
    /// The local name of the base type definition, in the XML Schema
    /// namespace.
    public let base: String
    /// The facets of the restriction, in document order.
    public let facets: [GivenFacet]
    /// The `source` of the definition's documentation, the section of the
    /// specification that defines the datatype.
    public let source: String?
    /// The text of the definition's documentation.
    public let documentation: String

    /// The definition an `xs:simpleType` element gives, or `nil` for one
    /// that is not a restriction of a named base (a list or union type,
    /// such as `xsd:NMTOKENS`).
    public init?(_ element: SchemaElement, vocabulary: FacetVocabulary) throws {
        let namespace = vocabulary.namespace
        guard let name = element.attributes["name"],
              let restriction = element.children("restriction", in: namespace).first,
              let baseName = restriction.attributes["base"] else { return nil }
        let base = try restriction.resolve(qualifiedName: baseName)
        guard base.namespace == namespace else {
            throw DefinitionError(description: "\(name): its base \(baseName) is not an XML Schema datatype")
        }
        var facets: [GivenFacet] = []
        for child in restriction.children where child.namespace == namespace && child.localName != "annotation" {
            guard vocabulary.facets[child.localName] != nil else {
                throw DefinitionError(description: "\(name): \(child.localName) is not a facet the schema for schema documents declares")
            }
            guard let value = child.attributes["value"] else {
                throw DefinitionError(description: "\(name): its \(child.localName) has no value")
            }
            facets.append(GivenFacet(name: child.localName, value: value))
        }
        let documentation = element.children("annotation", in: namespace).flatMap { $0.children("documentation", in: namespace) }
        self.name = name
        self.base = base.localName
        self.facets = facets
        self.source = documentation.lazy.compactMap { $0.attributes["source"] }.first
        self.documentation = documentation.map(\.text).joined(separator: "\n")
    }
}
