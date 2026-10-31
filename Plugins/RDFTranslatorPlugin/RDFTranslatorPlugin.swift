import Foundation
import PackagePlugin

/// Translates a target's RDF documents (`.rdf`, `.ttl`) to the Swift they
/// describe, on every build.
///
/// The documents at the target's root are one vocabulary, whose terms are
/// the module's own: FOAF's `index.rdf` gives `FOAF.Person`. The documents
/// in a subdirectory are a vocabulary named for it, whose terms are nested
/// in a namespace of that name: RDFKit's `RDFS/rdfs.ttl` gives
/// `RDFS.Resource`. Each vocabulary is translated with every other one of
/// its target and of the targets it depends on as a layer it builds on.
@main
struct RDFTranslatorPlugin: BuildToolPlugin {
    static let extensions: Set<String> = ["rdf", "ttl"]

    /// One vocabulary: its module, its namespace if nested, its documents.
    struct Vocabulary {
        let module: String
        let namespace: String?
        let documents: [URL]

        var arguments: [String] { [module, namespace ?? "-"] + documents.map(\.path) }
    }

    func createBuildCommands(context: PluginContext, target: any Target) throws -> [Command] {
        guard let target = target as? any SourceModuleTarget else { return [] }
        let own = Self.vocabularies(of: target)
        let layers = target.recursiveTargetDependencies.compactMap { $0 as? any SourceModuleTarget }.flatMap(Self.vocabularies)
        return try own.map { vocabulary in
            let output = context.pluginWorkDirectoryURL.appending(path: "\(target.moduleName)+\(vocabulary.namespace ?? "Terms").swift")
            let others = own.filter { $0.namespace != vocabulary.namespace } + layers
            return .buildCommand(
                displayName: "Translating \(vocabulary.namespace ?? target.moduleName) to Swift",
                executable: try context.tool(named: "RDFTranslator").url,
                arguments: [output.path] + vocabulary.arguments + others.flatMap { ["--layer"] + $0.arguments },
                inputFiles: ([vocabulary] + others).flatMap(\.documents),
                outputFiles: [output]
            )
        }
    }

    /// A target's vocabularies: its RDF documents, by directory.
    static func vocabularies(of target: any SourceModuleTarget) -> [Vocabulary] {
        let root = target.directoryURL.standardizedFileURL.pathComponents
        let documents = target.sourceFiles.map(\.url).filter { extensions.contains($0.pathExtension.lowercased()) }.sorted { $0.path < $1.path }
        var groups: [String?: [URL]] = [:]
        var order: [String?] = []
        for document in documents {
            let components = document.standardizedFileURL.pathComponents
            let relative = components.count > root.count + 1 ? components[root.count] : nil
            if groups[relative] == nil { order.append(relative) }
            groups[relative, default: []].append(document)
        }
        return order.map { Vocabulary(module: target.moduleName, namespace: $0, documents: groups[$0] ?? []) }
    }
}
