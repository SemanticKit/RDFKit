import Foundation
import PackagePlugin

/// Translates the semantic tables of the W3C specifications in a target's
/// `W3C` directory to Swift, on every build.
@main
struct SemanticsEmitterPlugin: BuildToolPlugin {
    static let documents = ["rdf12-semantics.html", "owl2-profiles.html", "owl2-rdf-based-semantics.html", "rdf12-schema.html"]

    func createBuildCommands(context: PluginContext, target: any Target) throws -> [Command] {
        let directory = target.directoryURL.appending(path: "W3C")
        let inputs = Self.documents.map { directory.appending(path: $0) }
        let output = context.pluginWorkDirectoryURL.appending(path: "\(target.name)+Semantics.swift")
        return [
            .buildCommand(
                displayName: "Translating the semantics of the W3C specifications to Swift",
                executable: try context.tool(named: "SemanticsEmitter").url,
                arguments: [output.path] + inputs.map(\.path),
                inputFiles: inputs,
                outputFiles: [output]
            )
        ]
    }
}
