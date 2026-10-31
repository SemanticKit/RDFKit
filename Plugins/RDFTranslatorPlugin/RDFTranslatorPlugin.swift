import Foundation
import PackagePlugin

/// Translates the terms a target lists in its `units.txt` from the target's
/// RDF documents (`.rdf`, `.ttl`) to Swift, on every build.
@main
struct RDFTranslatorPlugin: BuildToolPlugin {
    static let extensions: Set<String> = ["rdf", "ttl"]

    func createBuildCommands(context: PluginContext, target: any Target) throws -> [Command] {
        guard let target = target as? any SourceModuleTarget else { return [] }
        let files = target.sourceFiles.map(\.url)
        let documents = files.filter { Self.extensions.contains($0.pathExtension.lowercased()) }.sorted { $0.path < $1.path }
        guard let units = files.first(where: { $0.lastPathComponent == "units.txt" }) else { return [] }
        let output = context.pluginWorkDirectoryURL.appending(path: "\(target.moduleName)+Terms.swift")
        return [
            .buildCommand(
                displayName: "Translating the terms of \(target.moduleName) to Swift",
                executable: try context.tool(named: "RDFTranslator").url,
                arguments: [output.path, units.path, target.moduleName] + documents.map(\.path),
                inputFiles: [units] + documents,
                outputFiles: [output]
            )
        ]
    }
}
