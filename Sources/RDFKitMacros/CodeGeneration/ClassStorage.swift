import Foundation

/// The names of the generated declarations that store the property values of
/// a class's individuals.
///
/// Every class protocol `Q.N` comes with a values struct `Q.NValues` that
/// holds the class's own properties, and a slot `_Q_N` of that type in the
/// values of each subclass. The protocol requires `_withQ_NValues`, which reads
/// or changes those values, and `@ClassProtocol` implements the class's
/// properties on top of it.
///
/// The names follow from the class's qualified spelling alone, so an ontology
/// that refines another ontology's class (`OWL.Class` refining `RDFS.Class`)
/// names that class's values without seeing its declaration.
struct ClassStorage: Equatable {
    /// The qualified class spelling, `RDFS.Class`.
    let classSpelling: String
    /// The values struct, `RDFS.ClassValues`.
    let valuesType: String
    /// The slot that holds those values inside a subclass's values, `_RDFS_Class`.
    let slot: String
    /// The requirement that reads or changes the values, `_withRDFS_ClassValues`.
    let accessor: String

    /// The storage names of the class `name` declared in the ontology `ontology`.
    init(ontology: String, name: String) {
        let ontology = Self.plain(ontology)
        let name = SwiftIdentifier.sanitized(Self.plain(name))
        classSpelling = "\(ontology).\(SwiftIdentifier.escaped(name))"
        valuesType = "\(ontology).\(name)Values"
        slot = "_\(ontology)_\(name)"
        accessor = "_with\(ontology)_\(name)Values"
    }

    /// The storage names of a class written as `Ontology.Name`, or nil when the
    /// spelling does not name the ontology. A longer path (`RDFKit.RDFS.Class`)
    /// names the ontology by its last two components.
    init?(spelling: String) {
        let components = spelling.split(separator: ".").map(String.init)
        guard components.count >= 2 else { return nil }
        self.init(ontology: components[components.count - 2], name: components[components.count - 1])
    }

    /// The storage names of a class whose values type is spelled `Q.NValues`.
    init?(valuesType: String) {
        guard valuesType.hasSuffix("Values") else { return nil }
        self.init(spelling: String(valuesType.dropLast("Values".count)))
    }

    /// The local name of the values struct inside its ontology, `ClassValues`.
    var localValuesName: String {
        String(valuesType.split(separator: ".").last ?? "")
    }

    /// The declaration of the requirement, without a body.
    var accessorSignature: String {
        "func \(accessor)<Result: Sendable>(_ body: (inout \(valuesType)) -> Result) -> Result"
    }

    private static func plain(_ identifier: String) -> String {
        identifier.replacingOccurrences(of: "`", with: "")
    }
}
