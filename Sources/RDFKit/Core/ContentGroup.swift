import Foundation

/// A group of authored RDF content values.
public struct ContentGroup: Content {
    let elements: [any Content]

    init(_ elements: [any Content]) {
        self.elements = elements
    }
}
