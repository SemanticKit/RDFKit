import Foundation

/// An RDF term.
///
/// RDF 1.2 Concepts §3.2 RDF Terms: "IRIs, literals, blank nodes, and triple
/// terms are collectively known as RDF terms."
public protocol Term: Node {}
