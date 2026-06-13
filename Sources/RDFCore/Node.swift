import Foundation

/// An RDF graph node.
///
/// RDF 1.2 Concepts §1.1 Graph-based Abstract Data Model: "There are four
/// kinds of nodes that can be in an RDF graph: IRIs, literals, blank nodes, and
/// triple terms."
///
/// RDF 1.2 Concepts §3.1 Triples: "The set of nodes of an RDF graph is the
/// set of subjects and objects of the asserted triples of the graph."
public protocol Node: Sendable {}

/// An RDF triple subject.
///
/// RDF 1.2 Concepts §3.1 Triples: "The subject, which is an IRI or a blank
/// node".
public protocol Subject: Term {}

/// An RDF triple predicate.
///
/// RDF 1.2 Concepts §3.1 Triples: "The predicate, which is an IRI".
public protocol Predicate: Term {}

/// An RDF triple object.
///
/// RDF 1.2 Concepts §3.1 Triples: "The object, which is an IRI, a blank node,
/// a literal, or an RDF triple."
public protocol Object: Term {}
