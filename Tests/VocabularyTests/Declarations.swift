import RDFCore

/// The number of terms of each kind an ontology's content declares.
struct Declarations: Equatable, CustomStringConvertible {
    var classes = 0
    var datatypes = 0
    var properties = 0
    var individuals = 0

    init(classes: Int = 0, datatypes: Int = 0, properties: Int = 0, individuals: Int = 0) {
        self.classes = classes
        self.datatypes = datatypes
        self.properties = properties
        self.individuals = individuals
    }

    init(of ontology: some Ontology) {
        for entity in ontology.content() {
            switch entity {
            case is RDFCore.Class: classes += 1
            case is RDFCore.Datatype: datatypes += 1
            case is RDFCore.Property: properties += 1
            case is RDFCore.Individual: individuals += 1
            default: break
            }
        }
    }

    var description: String {
        "\(classes) classes, \(datatypes) datatypes, \(properties) properties, \(individuals) individuals"
    }
}
