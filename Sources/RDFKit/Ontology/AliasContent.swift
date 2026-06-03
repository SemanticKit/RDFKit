import Foundation

/// Ontology alias content.
public protocol AliasContent: Content {}

/// An empty alias content value.
public struct EmptyAliasContent: AliasContent {
    /// Creates empty alias content.
    public init() {}
}

extension EmptyAliasContent: AliasMappingContent {
    /// Adds no aliases to the IRI prefix map.
    func addIRIPrefixes(to map: inout [String: IRI]) throws {}
}

/// A prefix alias bound to a namespace target.
public struct Alias<Target: AliasTarget>: AliasContent {
    /// The alias prefix.
    public let prefix: String

    /// The target namespace value.
    public let target: Target

    /// Creates a prefix alias.
    public init(_ prefix: String, _ target: Target) {
        self.prefix = prefix
        self.target = target
    }

    /// Creates a prefix alias bound to a vocabulary type.
    public init<VocabularyValue: Vocabulary>(_ prefix: String, _ target: VocabularyValue.Type) where Target == VocabularyAliasTarget<VocabularyValue> {
        self.prefix = prefix
        self.target = VocabularyAliasTarget(target)
    }
}

extension Alias: AliasMappingContent {
    /// Adds this alias to the IRI prefix map.
    func addIRIPrefixes(to map: inout [String: IRI]) throws {
        if map[prefix] != nil {
            throw AliasResolutionError.duplicatePrefix(prefix)
        }

        map[prefix] = try target.aliasNamespace().iri
    }
}

/// A group of alias content values.
public struct AliasGroup: AliasContent {
    /// The alias content values.
    public let elements: [any AliasContent]

    /// Creates an alias group.
    public init(_ elements: [any AliasContent]) {
        self.elements = elements
    }
}

extension AliasGroup: AliasMappingContent {
    /// Adds the grouped aliases to the IRI prefix map.
    func addIRIPrefixes(to map: inout [String: IRI]) throws {
        for element in elements {
            guard let mappingContent = element as? any AliasMappingContent else {
                throw AliasResolutionError.unsupportedAliasContent(String(describing: type(of: element)))
            }

            try mappingContent.addIRIPrefixes(to: &map)
        }
    }
}

/// Builds protocol-based alias content.
@resultBuilder
public enum AliasBuilder {
    public static func buildBlock() -> EmptyAliasContent {
        EmptyAliasContent()
    }

    public static func buildBlock<Content: AliasContent>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock(_ content: any AliasContent...) -> AliasGroup {
        AliasGroup(content)
    }
}
