import Testing
import RDFKit

/// A Swift class whose instances are OWL classes.
private final class OWLClass: OWL.Class {}

@Suite struct ClassHierarchyTests {
    /// owl:Class rdfs:subClassOf rdfs:Class, and rdfs:Class rdfs:subClassOf
    /// rdfs:Resource, hold as protocol inheritance.
    @Test func owlClassIsAnRDFSClassAndAResource() {
        let member: AnyObject = OWLClass()
        #expect(member is OWL.Class)
        #expect(member is RDFS.Class)
        #expect(member is RDFS.Resource)
    }

    /// A resource is a Swift object, and its identity is the object's (D3).
    @Test func resourceIdentityIsObjectIdentity() {
        let first: any RDFS.Resource = OWLClass()
        let second: any RDFS.Resource = OWLClass()
        #expect(first === first)
        #expect(first !== second)
    }
}
