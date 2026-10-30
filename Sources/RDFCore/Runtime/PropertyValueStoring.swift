/// An individual that keeps its property values in an ``IndividualStorage``.
///
/// The storing protocol generated for a property, `FOAF.knowsStoring`,
/// refines it and gives the property its accessor through the storage. The
/// storing protocol of a class, `FOAF.PersonStoring`, refines the class's
/// protocol and the storing protocols of the properties its members can have
/// and of its superclasses. Every individual's class conforms to the storing
/// protocols of its classes, whichever ontology or module declares them, so
/// an individual typed with classes of several vocabularies has all of their
/// properties, each once.
///
/// An individual's Swift class states the classes its instances are members
/// of as ``classes``, and its `Encodable` conformance writes them as
/// `rdf:type`, then the property values:
///
///     final class PersonAndEmployee: People.PersonStoring, Staff.EmployeeStoring {
///         static let classes: [any ResourceClass.Type] = [People.PersonIndividual.self, Staff.EmployeeIndividual.self]
///         let iri: IRI? = nil
///         let storage = IndividualStorage()
///     }
public protocol PropertyValueStoring: Resource {
    /// The classes an instance of this Swift class is a member of, which its
    /// encoding writes as `rdf:type`. The superclasses they refine follow
    /// from them (RDF 1.2 Semantics, rdfs9), so they are not listed.
    static var classes: [any ResourceClass.Type] { get }

    /// The individual's property values.
    var storage: IndividualStorage { get }
}

extension PropertyValueStoring {
    /// Writes the individual's classes as `rdf:type`, then its property
    /// values.
    public func encode(to encoder: any Encoder) throws {
        if !Self.classes.isEmpty {
            var container = encoder.container(keyedBy: PropertyKey.self)
            try container.encode(Self.classes, for: .type)
        }
        try storage.encode(to: encoder)
    }
}
