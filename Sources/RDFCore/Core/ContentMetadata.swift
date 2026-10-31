import IRIKit

public protocol ContentMetadata: Codable, Identifiable, Sendable {
    var id: IRI { get }
    var name: String { get }
}
