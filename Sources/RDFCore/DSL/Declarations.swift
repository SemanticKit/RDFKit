/// The namespace of the vocabulary's terms: `Namespace("http://xmlns.com/foaf/0.1/")`.
public struct Namespace: Content {
    public init(_ iri: String) {}
}

/// A class (`rdfs:Class`), named by its local name, with its annotations.
public struct Class: Content {
    public init(_ name: String, @ContentBuilder _ annotations: () -> some Content) {}
}

/// The class a declared term is a member of (`rdf:type`):
/// `Type(RDFS.Class.self)`.
public struct Type: Content {
    public init(_ class: Any.Type) {}
}

/// A class the declared class is a subclass of (`rdfs:subClassOf`):
/// `SubClassOf(RDFS.Resource.self)`.
public struct SubClassOf: Content {
    public init(_ class: Any.Type) {}
}

/// A human-readable name for the declared term (`rdfs:label`).
public struct Label: Content {
    public init(_ label: String) {}
}

/// A description of the declared term (`rdfs:comment`).
public struct Comment: Content {
    public init(_ comment: String) {}
}
