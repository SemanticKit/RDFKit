import Foundation
import RDFCore
import RDFFormats

/// An N-Triples document in `Fixtures`, decoded at the boundary.
enum Fixture {
    static func graph(_ name: String) throws -> Graph {
        try NTriplesDecoder().decode(try text(name))
    }

    static func text(_ name: String) throws -> String {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "Fixtures/\(name)")
        return try String(contentsOf: url, encoding: .utf8)
    }
}

extension Graph {
    /// The graph encoded as Turtle and decoded again.
    func roundTripped() throws -> Graph {
        try TurtleDecoder().decode(TurtleEncoder().encode(self))
    }

    /// The literal objects of the graph's triples, in document order.
    var literals: [Literal] {
        compactMap { triple in
            guard case .literal(let literal) = triple.object else { return nil }
            return literal
        }
    }
}
