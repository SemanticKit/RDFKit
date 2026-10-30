import Foundation

/// Translates the RDF documents of a Swift target into the Swift the
/// documents describe. The `RDFTranslatorPlugin` runs it on every build.
///
///     RDFTranslator <output.swift> [--datatypes <Name> <document>...] (--module <Name> <document>...)...
///
/// Each `--module` names a module and its documents, lowest layer first; the
/// last is the module the output belongs to. The others are the layers it
/// builds on, whose declarations it uses. Below them all is the module
/// `--datatypes` names, `XSD`, with the W3C documents it is translated from,
/// whose datatypes type the properties that range over them.
do {
    var arguments = CommandLine.arguments.dropFirst()
    guard let output = arguments.popFirst() else {
        throw TranslationError(description: "usage: RDFTranslator <output.swift> [--datatypes <Name> <document>...] (--module <Name> <document>...)...")
    }
    var datatypeGroup: (module: String, paths: [String])?
    var groups: [(module: String, paths: [String])] = []
    while let argument = arguments.popFirst() {
        if argument == "--datatypes" {
            guard let module = arguments.popFirst() else { throw TranslationError(description: "--datatypes needs a name") }
            guard groups.isEmpty else { throw TranslationError(description: "--datatypes comes before the modules") }
            datatypeGroup = (module, [])
        } else if argument == "--module" {
            guard let module = arguments.popFirst() else { throw TranslationError(description: "--module needs a name") }
            groups.append((module, []))
        } else if groups.isEmpty, datatypeGroup != nil {
            datatypeGroup?.paths.append(argument)
        } else {
            guard !groups.isEmpty else { throw TranslationError(description: "\(argument): name its module with --module first") }
            groups[groups.count - 1].paths.append(argument)
        }
    }
    guard !groups.isEmpty else { throw TranslationError(description: "no module to translate") }

    // The XSD datatypes are the layer below every module.
    let datatypes = try datatypeGroup.map { try DatatypeLayer(module: $0.module, documents: $0.paths) } ?? DatatypeLayer()
    var layers: [Layer] = []
    var declarations: [Declarations] = [datatypes.declarations]
    var vocabulary = Vocabulary([], datatypes: datatypes)
    var documents = 0
    for group in groups {
        let layer = try Layer(module: group.module, paths: group.paths, firstDocument: documents)
        documents += group.paths.count
        layers.append(layer)
        vocabulary = Vocabulary(layers, datatypes: datatypes)
        declarations.append(try Declarations(layer, vocabulary, below: declarations))
    }
    let source = SwiftSource(
        layer: layers[layers.count - 1],
        vocabulary: vocabulary,
        declarations: declarations[declarations.count - 1],
        below: Array(declarations.dropLast())
    ).render()
    try source.write(to: URL(filePath: output), atomically: true, encoding: .utf8)
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(1)
}
