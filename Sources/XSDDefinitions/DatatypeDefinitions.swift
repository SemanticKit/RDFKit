import Foundation

/// The XML Schema datatypes RDF uses, as the W3C documents define them.
///
/// The documents are the W3C's own, read as their structure gives them:
///
/// - `.xsd`: the schema for schema documents of XML Schema 1.1 Part 2
///   (Appendix A, `datatypes.xsd`), which declares the constraining facets.
/// - `.nxsd`: the XML representations of the built-in datatype definitions
///   (Appendix C.1 `primitives.nxsd` and C.2 `derived.nxsd`), which give each
///   datatype its base and its facets.
/// - `.html`: RDF 1.2 Concepts, whose §5.1 lists the datatypes RDF uses, "the
///   RDF-compatible XSD types", and whose §1.4 gives the `xsd` namespace.
///
/// The schema documents give the definitions and their hierarchy; §5.1
/// selects which of them RDF uses. Appendix C also defines datatypes RDF 1.2
/// leaves out (`ID`, `IDREF`, `ENTITY`, `QName`, `NOTATION`, and the list
/// types), which ``defined`` holds and ``datatypes`` does not.
///
/// `XSDTranslator` turns ``datatypes`` into the Swift value types of the `XSD`
/// module, and `RDFTranslator` reads the same documents to type the
/// properties that range over them, so both translators learn the datatypes
/// from one translation.
public struct DatatypeDefinitions: Sendable {
    /// The file names of the documents, in the order given.
    public let documents: [String]

    /// The constraining facets, from the schema for schema documents.
    public let vocabulary: FacetVocabulary

    /// The namespace of the datatypes, the `xsd` namespace of RDF 1.2
    /// Concepts §1.4.
    public let namespace: String

    /// Every top-level restriction the schema documents define, in document
    /// order.
    public let defined: [SimpleTypeDefinition]

    /// The datatypes RDF 1.2 Concepts §5.1 lists, in its order, each as the
    /// schema documents define it.
    public let datatypes: [SimpleTypeDefinition]

    /// Reads the documents at `paths`.
    ///
    /// - Throws: ``DefinitionError`` when a document is missing or not as its
    ///   specification gives it, when §5.1 lists a datatype no schema document
    ///   defines, or when a listed datatype is derived from one §5.1 does not
    ///   list.
    public init(documents paths: [String]) throws {
        let extensions = paths.map { URL(filePath: $0).pathExtension.lowercased() }
        guard let schemaPath = zip(paths, extensions).first(where: { $1 == "xsd" })?.0 else {
            throw DefinitionError(description: "no schema for schema documents (.xsd)")
        }
        guard let conceptsPath = zip(paths, extensions).first(where: { $1 == "html" })?.0 else {
            throw DefinitionError(description: "no RDF 1.2 Concepts document (.html)")
        }
        let vocabulary = try FacetVocabulary(schema: try SchemaElement(document: schemaPath))
        var defined: [SimpleTypeDefinition] = []
        for (path, pathExtension) in zip(paths, extensions) where pathExtension == "nxsd" {
            let schema = try SchemaElement(document: path)
            for element in schema.children("simpleType", in: vocabulary.namespace) {
                guard let definition = try SimpleTypeDefinition(element, vocabulary: vocabulary) else { continue }
                guard !defined.contains(where: { $0.name == definition.name }) else {
                    throw DefinitionError(description: "\(path): xsd:\(definition.name) is defined twice")
                }
                defined.append(definition)
            }
        }
        let compatible = try CompatibleDatatypes(concepts: try String(contentsOf: URL(filePath: conceptsPath), encoding: .utf8))
        guard compatible.namespace.hasPrefix(vocabulary.namespace) else {
            throw DefinitionError(description: "the xsd namespace of RDF 1.2 Concepts, \(compatible.namespace), is not the XML Schema namespace \(vocabulary.namespace)")
        }
        let datatypes = try compatible.names.map { name in
            guard let definition = defined.first(where: { $0.name == name }) else {
                throw DefinitionError(description: "RDF 1.2 Concepts lists xsd:\(name), which no schema document defines")
            }
            return definition
        }
        for definition in datatypes where definition.base != Self.atomicBase {
            guard datatypes.contains(where: { $0.name == definition.base }) else {
                throw DefinitionError(description: "xsd:\(definition.name) is derived from xsd:\(definition.base), which RDF 1.2 Concepts does not list")
            }
        }
        self.documents = paths.map { URL(filePath: $0).lastPathComponent }
        self.vocabulary = vocabulary
        self.namespace = compatible.namespace
        self.defined = defined
        self.datatypes = datatypes
    }

    /// The base of the primitive datatypes, `xsd:anyAtomicType`, which RDF
    /// does not use.
    public static let atomicBase = "anyAtomicType"

    /// The listed datatype named `name`.
    public func datatype(named name: String) -> SimpleTypeDefinition? {
        datatypes.first { $0.name == name }
    }

    /// The listed datatypes derived from `definition` in one step, in the
    /// order of §5.1.
    public func derivations(of definition: SimpleTypeDefinition) -> [SimpleTypeDefinition] {
        datatypes.filter { $0.base == definition.name }
    }

    /// The definitions from the primitive down to `definition`.
    public func chain(to definition: SimpleTypeDefinition) -> [SimpleTypeDefinition] {
        var chain = [definition]
        while chain[0].base != Self.atomicBase, let base = datatype(named: chain[0].base) {
            chain.insert(base, at: 0)
        }
        return chain
    }
}

/// Why the documents give no datatypes.
public struct DefinitionError: Error, CustomStringConvertible {
    public let description: String

    public init(description: String) {
        self.description = description
    }
}
