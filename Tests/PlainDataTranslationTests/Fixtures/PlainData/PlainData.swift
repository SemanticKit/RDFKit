// Data with no vocabulary below it (people.ttl, namespaces.ttl), translated
// to Swift.
//
// RDFTranslatorPlugin writes the Swift these documents describe on every
// build. This target depends on RDFCore alone, so no layer below it
// declares a class or a property: `rdf:type` names no class here. A Swift
// target needs a Swift source file of its own; this is it.
