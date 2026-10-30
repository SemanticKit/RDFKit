import Foundation
import PackagePlugin

/// Translates a target's RDF documents to Swift on every build.
///
/// The documents of the target are its `.ttl`, `.nt` and `.rdf` files. The
/// documents of the targets it depends on, directly or not, are the layers
/// it builds on: the translator reads them to know what those modules
/// declare, so a vocabulary refers to the Swift its layers were translated
/// into.
@main
struct RDFTranslatorPlugin: BuildToolPlugin {
    static let extensions: Set<String> = ["ttl", "nt", "rdf"]

    func createBuildCommands(context: PluginContext, target: any Target) throws -> [Command] {
        guard let target = target as? any SourceModuleTarget else { return [] }
        var groups: [String] = []
        var inputs: [URL] = []
        for layer in Self.layers(below: target) + [target] {
            let documents = Self.documents(of: layer)
            groups += ["--module", layer.moduleName] + documents.map(\.path)
            inputs += documents
        }
        let output = context.pluginWorkDirectoryURL.appending(path: "\(target.moduleName)+RDF.swift")
        return [
            .buildCommand(
                displayName: "Translating the RDF of \(target.moduleName) to Swift",
                executable: try context.tool(named: "RDFTranslator").url,
                arguments: [output.path] + groups,
                inputFiles: inputs,
                outputFiles: [output]
            )
        ]
    }

    /// The RDF documents of a target, in file order.
    static func documents(of target: any SourceModuleTarget) -> [URL] {
        target.sourceFiles.map(\.url)
            .filter { extensions.contains($0.pathExtension.lowercased()) }
            .sorted { $0.path < $1.path }
    }

    /// The targets a target depends on that have RDF documents, each after
    /// the targets it depends on.
    static func layers(below target: any SourceModuleTarget) -> [any SourceModuleTarget] {
        var ordered: [any SourceModuleTarget] = []
        var visited: Set<String> = []
        func visit(_ dependency: any Target) {
            guard visited.insert(dependency.id).inserted else { return }
            for next in dependency.dependencies {
                switch next {
                case .target(let target): visit(target)
                case .product(let product): product.targets.forEach(visit)
                @unknown default: break
                }
            }
            if let module = dependency as? any SourceModuleTarget, !documents(of: module).isEmpty {
                ordered.append(module)
            }
        }
        for next in target.dependencies {
            switch next {
            case .target(let target): visit(target)
            case .product(let product): product.targets.forEach(visit)
            @unknown default: break
            }
        }
        return ordered
    }
}
