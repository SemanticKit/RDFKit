import Foundation
import IRIKit

/// An RDF term represented by an IRI.
public protocol Term: Identifiable, Subject, Predicate, Object where ID == IRI {}
