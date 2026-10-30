import Foundation
import PackagePlugin

/// Translates the W3C documents that define the XML Schema datatypes RDF
/// uses into their Swift value types, on every build.
///
/// The documents of the target are its `.xsd`, `.nxsd` and `.html` files:
/// the schema for schema documents of XML Schema 1.1 Part 2, the XML
/// representations of the built-in datatype definitions, and RDF 1.2
/// Concepts, whose §5.1 lists the datatypes RDF uses.
@main
struct XSDTranslatorPlugin: BuildToolPlugin {
    static let extensions: Set<String> = ["xsd", "nxsd", "html"]

    func createBuildCommands(context: PluginContext, target: any Target) throws -> [Command] {
        guard let target = target as? any SourceModuleTarget else { return [] }
        let documents = target.sourceFiles.map(\.url)
            .filter { Self.extensions.contains($0.pathExtension.lowercased()) }
            .sorted { $0.path < $1.path }
        let output = context.pluginWorkDirectoryURL.appending(path: "\(target.moduleName)+Datatypes.swift")
        return [
            .buildCommand(
                displayName: "Translating the XML Schema datatypes of \(target.moduleName) to Swift",
                executable: try context.tool(named: "XSDTranslator").url,
                arguments: [output.path] + documents.map(\.path),
                inputFiles: documents,
                outputFiles: [output]
            )
        ]
    }
}
