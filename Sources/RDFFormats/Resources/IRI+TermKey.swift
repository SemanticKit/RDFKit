import IRIKit
import RDFCore

extension IRI {
    /// The IRI a declared key gives: its vocabulary's namespace followed by
    /// its declared name, derived when a coder or a comparison at the
    /// boundary asks for it. `nil` when the text is not an IRI.
    public init?(_ key: TermKey) {
        try? self.init(validating: key.stringValue)
    }

    /// The IRI of a named individual, or `nil` for one no declaration names
    /// (a blank node at the boundary).
    public init?(of individual: any Resource) {
        guard let key = type(of: individual).key else { return nil }
        self.init(key)
    }

    /// The IRI of a class, or `nil` for one no declaration names.
    public init?(of class: any ResourceClass.Type) {
        guard let key = `class`.classKey else { return nil }
        self.init(key)
    }
}
