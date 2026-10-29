import Foundation

/// Translates the RDF documents of a Swift target into the Swift the
/// documents describe. The `RDFTranslatorPlugin` runs it on every build.
///
///     RDFTranslator <output.swift> (--module <Name> <document>...)...
///
/// Each `--module` names a module and its documents, lowest layer first; the
/// last is the module the output belongs to. The others are the layers it
/// builds on, whose declarations it uses.
do {
    var arguments = CommandLine.arguments.dropFirst()
    guard let output = arguments.popFirst() else {
        throw TranslationError(description: "usage: RDFTranslator <output.swift> (--module <Name> <document>...)...")
    }
    var groups: [(module: String, paths: [String])] = []
    while let argument = arguments.popFirst() {
        if argument == "--module" {
            guard let module = arguments.popFirst() else { throw TranslationError(description: "--module needs a name") }
            groups.append((module, []))
        } else {
            guard !groups.isEmpty else { throw TranslationError(description: "\(argument): name its module with --module first") }
            groups[groups.count - 1].paths.append(argument)
        }
    }
    guard !groups.isEmpty else { throw TranslationError(description: "no module to translate") }

    var layers: [Layer] = []
    var declarations: [Declarations] = []
    var vocabulary = Vocabulary([])
    var documents = 0
    for group in groups {
        let layer = try Layer.read(module: group.module, paths: group.paths, firstDocument: documents)
        documents += group.paths.count
        layers.append(layer)
        vocabulary = Vocabulary(layers)
        declarations.append(Declarations(layer, vocabulary, below: declarations))
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
