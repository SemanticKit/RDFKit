import RDFCore
import RDFKit

/// The W3C Basic Geo (WGS84 lat/long) vocabulary.
///
/// Namespace `http://www.w3.org/2003/01/geo/wgs84_pos#`. Only the terms the Solid vocabularies
/// name are declared here: `SpatialThing`.
/// It is declared with its published type, label and comment; its other
/// statements, and the rest of the vocabulary, are not.
@Ontology
public struct Geo: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/2003/01/geo/wgs84_pos#")

        Class("SpatialThing") {
            Type(RDFS.Class)
            Label("SpatialThing")
            Comment("Anything with spatial extent, i.e. size, shape, or position. e.g. people, places, bowling balls, as well as abstract areas like cubes.")
        }
    }
}
