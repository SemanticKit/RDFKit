import Foundation

public extension RDF {
    /// Returns an rdf container membership property IRI.
    static func containerMembershipProperty(_ index: Int) throws -> IRI {
        guard index > 0 else {
            throw RDFTermError.invalidContainerMembershipIndex
        }
        return IRI("\(RDF.declaredNamespace.rawValue)_\(index)")
    }
}
