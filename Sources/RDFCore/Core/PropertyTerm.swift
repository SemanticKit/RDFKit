/// A property whose values an individual keeps under the property's term.
///
/// A property whose `Domain` is a class of its own ontology is a requirement
/// of that class's protocol: `alice.knows`. A property whose domain is
/// another ontology's class, or that has no domain, cannot add a requirement
/// to a protocol it does not declare. Its term type conforms to
/// `PropertyTerm` instead, and the `@Ontology` macro gives the term a static
/// subscript that takes the subject, typed by the property's `Domain`, and
/// returns a view of its values, typed by the property's `Range`:
///
///     Cert.key[alice].append(aliceKey)   // cert:key has the domain foaf:Agent
///     Solid.oidcIssuer[alice].values      // solid:oidcIssuer has no domain
///
/// The term type is the key its values are kept under, so two ontologies that
/// describe the same individual never mix up their values, and no IRI or name
/// stands in for the property. A term's initializer is private to its
/// generated type, so its values are reached only through the subscript,
/// which checks the domain.
public protocol PropertyTerm: Entity, Hashable {
    /// The type of one value: the property's `Range`.
    associatedtype Range: Sendable
}
