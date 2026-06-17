import RDFCore
import IRIKit

/// Static IRI term references for the RDF vocabulary.
///
/// These properties provide convenient access to IRI terms defined in the
/// RDF ontology. The source of truth is the DSL content in `RDF.content`;
/// these are reference points for cross-ontology annotations.
///
/// Cross-ontology usage:
///     Type(RDFTerm.Property)
///     Domain(RDFTerm.List)
public enum RDFTerm {
    /// rdf:Property
    public static let Property: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property"
    /// rdf:List
    public static let List: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#List"
    /// rdf:Statement
    public static let Statement: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement"
    /// rdf:CompoundLiteral
    public static let CompoundLiteral: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#CompoundLiteral"
    /// rdf:PropositionForm
    public static let PropositionForm: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#PropositionForm"
    /// rdf:first
    public static let first: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#first"
    /// rdf:rest
    public static let rest: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest"
    /// rdf:nil
    public static let `nil`: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"
    /// rdf:type
    public static let `type`: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
    /// rdf:value
    public static let value: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#value"
    /// rdf:subject
    public static let subject: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#subject"
    /// rdf:predicate
    public static let predicate: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate"
    /// rdf:object
    public static let object: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#object"
    /// rdf:direction
    public static let direction: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#direction"
    /// rdf:language
    public static let language: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#language"
    /// rdf:reifies
    public static let reifies: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies"
    /// rdf:propositionFormObject
    public static let propositionFormObject: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#propositionFormObject"
    /// rdf:propositionFormPredicate
    public static let propositionFormPredicate: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#propositionFormPredicate"
    /// rdf:propositionFormSubject
    public static let propositionFormSubject: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#propositionFormSubject"
}
