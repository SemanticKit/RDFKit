import Foundation
import RDFCore
import RDFFormats

extension String {
    /// The text of a document in `Fixtures`.
    init(fixture name: String) throws {
        let url = URL(filePath: #filePath).deletingLastPathComponent()
            .appending(path: "../Fixtures/\(name)")
        self = try String(contentsOf: url, encoding: .utf8)
    }
}

extension Graph {
    /// The graph a document in `Fixtures` states, read by the decoder of its
    /// format: N-Triples for `.nt`, Turtle otherwise.
    init(fixture name: String) throws {
        let document = try String(fixture: name)
        self = name.hasSuffix(".nt") ? try NTriplesDecoder().decode(document) : try TurtleDecoder().decode(document)
    }

    /// The graph encoded as Turtle and decoded again.
    func roundTripped() throws -> Graph {
        try TurtleDecoder().decode(TurtleEncoder().encode(self))
    }

    /// The literal objects of the graph's triples, in the graph's order.
    var literals: [Literal] {
        compactMap { triple in
            if case .literal(let literal) = triple.object { literal } else { nil }
        }
    }
}
