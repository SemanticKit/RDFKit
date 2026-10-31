import IRIKit
import RDFCore
/// The terms of the RDFS vocabulary.
public enum RDFS {
}
extension RDFS {
    /// label: Resource
    ///
    /// comment: The class resource, everything.
    public protocol Resource {
    }
    /// label: Proposition
    ///
    /// comment: The class of propositions, simple logical expressions describing a relationship between two entities.
    public protocol Proposition: RDFS.Resource, AnyObject {
    }
    /// label: Class
    ///
    /// comment: The class of classes.
    public protocol Class: RDFS.Resource, AnyObject {
    }
    /// label: Literal
    ///
    /// comment: The class of literal values, eg. textual strings and integers.
    public protocol Literal: RDFS.Resource {
    }
    /// label: Container
    ///
    /// comment: The class of RDF containers.
    public protocol Container: RDFS.Resource, AnyObject {
    }
    /// label: ContainerMembershipProperty
    ///
    /// comment: The class of container membership properties, rdf:_1, rdf:_2, ..., all of which are sub-properties of 'member'.
    public protocol ContainerMembershipProperty: RDF.Property, AnyObject {
    }
    /// label: Datatype
    ///
    /// comment: The class of RDF datatypes.
    public protocol Datatype: RDFS.Class, AnyObject {
    }
    /// label: comment
    ///
    /// comment: A description of the subject resource.
    public protocol Comment: RDFS.Resource {
        /// label: comment
        ///
        /// comment: A description of the subject resource.
        var comment: Values<any RDFS.Literal> {
            get
            set
        }
    }
    /// label: label
    ///
    /// comment: A human-readable name for the subject.
    public protocol Label: RDFS.Resource {
        /// label: label
        ///
        /// comment: A human-readable name for the subject.
        var label: Values<any RDFS.Literal> {
            get
            set
        }
    }
    /// label: seeAlso
    ///
    /// comment: Further information about the subject resource.
    public protocol SeeAlso: RDFS.Resource {
        /// label: seeAlso
        ///
        /// comment: Further information about the subject resource.
        var seeAlso: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// label: isDefinedBy
    ///
    /// comment: The definition of the subject resource.
    public protocol IsDefinedBy: RDFS.Resource {
        /// label: isDefinedBy
        ///
        /// comment: The definition of the subject resource.
        var isDefinedBy: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// label: member
    ///
    /// comment: A member of the subject resource.
    public protocol Member: RDFS.Resource {
        /// label: member
        ///
        /// comment: A member of the subject resource.
        var member: Values<any RDFS.Resource> {
            get
            set
        }
    }
    /// The namespace the documents declare these terms in.
    public static var namespace: String {
        "http://www.w3.org/2000/01/rdf-schema#"
    }
}
