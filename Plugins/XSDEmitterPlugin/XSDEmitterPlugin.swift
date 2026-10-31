import Foundation
import PackagePlugin

/// Emits the Swift value types of the XML Schema datatypes a target lists in
/// its `units.txt`, from the W3C documents in the target (`.xsd`, `.nxsd`
/// and `.html`), on every build.
@main
struct XSDEmitterPlugin: BuildToolPlugin {
    static let extensions: Set<String> = ["xsd", "nxsd", "html"]

    func createBuildCommands(context: PluginContext, target: any Target) throws -> [Command] {
        guard let target = target as? any SourceModuleTarget else { return [] }
        let files = target.sourceFiles.map(\.url)
        let documents = files.filter { Self.extensions.contains($0.pathExtension.lowercased()) }.sorted { $0.path < $1.path }
        guard let units = files.first(where: { $0.lastPathComponent == "units.txt" }) else { return [] }
        let output = context.pluginWorkDirectoryURL.appending(path: "\(target.moduleName)+Datatypes.swift")
        return [
            .buildCommand(
                displayName: "Emitting the XML Schema datatypes of \(target.moduleName)",
                executable: try context.tool(named: "XSDEmitter").url,
                arguments: [output.path, units.path] + documents.map(\.path),
                inputFiles: [units] + documents,
                outputFiles: [output]
            )
        ]
    }
}
