import Foundation

/// A property whose object values are RDF resources.
public protocol ObjectProperty: Property {}

/// A property whose object values are RDF literals.
public protocol DatatypeProperty: Property {}

/// A property used for ontology annotations.
public protocol AnnotationProperty: Property {}

/// A property used at ontology scope.
public protocol OntologyProperty: Property {}

/// A property describing a relationship between resources.
public protocol RelationshipProperty: Property {}

/// A property with an RDFS domain.
public protocol DomainConstrainedProperty: Property {
    /// The domain term identities.
    static var domains: [IRI] { get }
}

/// A property with an RDFS range.
public protocol RangeConstrainedProperty: Property {
    /// The range term identities.
    static var ranges: [IRI] { get }
}

/// A property with known superproperties.
public protocol SubpropertyAwareProperty: Property {
    /// The direct superproperty identities.
    static var superproperties: [IRI] { get }
}
