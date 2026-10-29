import RDFCore

/// A triple read from a document: an RDFCore ``Triple`` whose subject and
/// object are the node kinds RDF 1.2 allows in those positions.
public typealias DecodedTriple = Triple<SubjectTerm, ObjectTerm>
