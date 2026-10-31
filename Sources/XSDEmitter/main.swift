import Foundation
import XSDDefinitions

/// Emits the Swift value type of each XML Schema datatype the `XSD` target
/// lists. `XSDEmitterPlugin` runs it on every build of that target.
///
///     XSDEmitter <output.swift> <units.txt> <document>...
///
/// The documents are the W3C's own, read by ``XSDDefinitions``; `units.txt`
/// names the datatypes translated so far, one per line.
do {
    var arguments = CommandLine.arguments.dropFirst()
    guard let output = arguments.popFirst(), let units = arguments.popFirst() else {
        throw EmitError(description: "usage: XSDEmitter <output.swift> <units.txt> <document>...")
    }
    let definitions = try DatatypeDefinitions(documents: Array(arguments))
    let names = try String(contentsOf: URL(filePath: units), encoding: .utf8)
        .split(whereSeparator: \.isNewline)
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }
    let source = try DatatypeEmitter(definitions: definitions).emit(names)
    try source.write(to: URL(filePath: output), atomically: true, encoding: .utf8)
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(1)
}

/// The error the emitter reports to the build.
struct EmitError: Error, CustomStringConvertible {
    let description: String
}
