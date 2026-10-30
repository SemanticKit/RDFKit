/// The description of a class: the triples stated about it, which its
/// Swift type writes.
public struct ClassDescription: Description {
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
