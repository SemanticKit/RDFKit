/// The description of a class: the triples stated about it, which its Swift
/// type writes. A class is a Swift type, not a value, so this is how its
/// description is listed with a module's other descriptions.
public struct ClassDescription: Sendable, Encodable {
    /// The class.
    public let `class`: any ResourceClass.Type

    /// The description of a class.
    public init(_ class: any ResourceClass.Type) {
        self.class = `class`
    }

    public func encode(to encoder: any Encoder) throws {
        try `class`.encodeDescription(to: encoder)
    }
}
