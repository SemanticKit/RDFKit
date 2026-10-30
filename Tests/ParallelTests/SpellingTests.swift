import Testing
import Foundation

/// The DSL is written the way inference-based Swift is written:
/// `SubClassOf(Animal)`, `Domain(Fauna.Animal)`, `Range(Fauna.Habitat)`.
/// Explicit generic arguments (`SubClassOf<Animal>()`, `RDFS.subClassOf<Animal>()`)
/// and `.self` term references are not the approved spelling (Charles,
/// 2026-10-29; DESIGN-CONTRACT.md rule 7). This test reads every Swift file in
/// the package's Sources and Tests and fails on either form.
@Suite struct SpellingTests {
    static let terms = [
        "Class", "Property", "SubClassOf", "SubPropertyOf", "Domain", "Range", "Type",
        "Datatype", "EquivalentClass", "EquivalentProperty", "DisjointWith", "InverseOf",
        "subClassOf", "subPropertyOf", "domain", "range", "equivalentClass",
        "equivalentProperty", "disjointWith", "inverseOf",
    ].joined(separator: "|")

    @Test func noExplicitGenericArgumentsInTheDSL() throws {
        let explicit = try Regex(#"(?:^|[^\w"])(?:\w+\.)?(?:\#(Self.terms))\s*<[^>]+>\s*\("#)
        let selfReference = try Regex(#"(?:^|[^\w"])(?:\#(Self.terms))\s*\(\s*[\w.]+\.self\s*\)"#)
        var offenders: [String] = []
        for file in try Self.swiftFiles() where !file.hasSuffix("SpellingTests.swift") {
            let lines = try String(contentsOfFile: file, encoding: .utf8).split(separator: "\n", omittingEmptySubsequences: false)
            for (number, line) in lines.enumerated() where line.contains(explicit) || line.contains(selfReference) {
                offenders.append("\(file):\(number + 1): \(line.trimmingCharacters(in: .whitespaces))")
            }
        }
        #expect(offenders.isEmpty, "Write the DSL by inference, e.g. SubClassOf(Animal):\n\(offenders.joined(separator: "\n"))")
    }

    static func swiftFiles() throws -> [String] {
        let root = URL(filePath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return ["Sources", "Tests"].flatMap { directory -> [String] in
            let base = root.appending(path: directory)
            guard let walker = FileManager.default.enumerator(at: base, includingPropertiesForKeys: nil) else { return [] }
            return walker.compactMap { ($0 as? URL)?.path(percentEncoded: false) }.filter { $0.hasSuffix(".swift") }
        }
    }
}
