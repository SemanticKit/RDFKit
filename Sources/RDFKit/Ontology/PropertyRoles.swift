import Foundation

/// A property whose object values are RDF resources.
public protocol ObjectProperty: RDFProperty {}

/// A property whose object values are RDF literals.
public protocol DatatypeProperty: RDFProperty {}

/// A property used for ontology annotations.
public protocol AnnotationProperty: RDFProperty {}

/// A property used at ontology scope.
public protocol OntologyProperty: RDFProperty {}

/// A property describing a relationship between resources.
public protocol RelationshipProperty: RDFProperty {}

/// A property with an RDFS domain.
public protocol DomainConstrainedProperty: RDFProperty {
    /// The domain term identities.
    static var domains: [IRI] { get }
}

/// A property with an RDFS range.
public protocol RangeConstrainedProperty: RDFProperty {
    /// The range term identities.
    static var ranges: [IRI] { get }
}

/// A property with known superproperties.
public protocol SubpropertyAwareProperty: RDFProperty {
    /// The direct superproperty identities.
    static var superproperties: [IRI] { get }
}
