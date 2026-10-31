import Foundation
import PackagePlugin

/// Translates the terms a target lists in its `units.txt` from the target's
/// RDF documents (`.rdf`, `.ttl`) to Swift, on every build. The vocabularies
/// of the targets it depends on that have a `units.txt` of their own are
/// handed to the translator as layers, so that it names their terms by
/// their Swift types.
@main
struct RDFTranslatorPlugin: BuildToolPlugin {
    static let extensions: Set<String> = ["rdf", "ttl"]

    func createBuildCommands(context: PluginContext, target: any Target) throws -> [Command] {
        guard let target = target as? any SourceModuleTarget, let own = Self.vocabulary(of: target) else { return [] }
        let layers = target.recursiveTargetDependencies.compactMap { $0 as? any SourceModuleTarget }.compactMap { dependency in
            Self.vocabulary(of: dependency).map { (module: dependency.moduleName, files: $0) }
        }
        let output = context.pluginWorkDirectoryURL.appending(path: "\(target.moduleName)+Terms.swift")
        var arguments = [output.path, own.units.path, target.moduleName] + own.documents.map(\.path)
        for layer in layers {
            arguments += ["--layer", layer.module, layer.files.units.path] + layer.files.documents.map(\.path)
        }
        return [
            .buildCommand(
                displayName: "Translating the terms of \(target.moduleName) to Swift",
                executable: try context.tool(named: "RDFTranslator").url,
                arguments: arguments,
                inputFiles: [own.units] + own.documents + layers.flatMap { [$0.files.units] + $0.files.documents },
                outputFiles: [output]
            )
        ]
    }

    /// A target's `units.txt` and RDF documents, when it has a `units.txt`.
    static func vocabulary(of target: any SourceModuleTarget) -> (units: URL, documents: [URL])? {
        let files = target.sourceFiles.map(\.url)
        guard let units = files.first(where: { $0.lastPathComponent == "units.txt" }) else { return nil }
        let documents = files.filter { extensions.contains($0.pathExtension.lowercased()) }.sorted { $0.path < $1.path }
        return (units, documents)
    }
}
