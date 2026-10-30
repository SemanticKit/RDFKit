import RDFCore

/// `xsd:boolean` (XML Schema 1.1 Part 2 §3.3.2): the values true and
/// false, written `true` or `1` and `false` or `0`.
extension boolean {
    public typealias Value = Bool

    /// ·booleanLexicalMap·.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> Bool {
        switch lexicalForm {
        case "true", "1": true
        case "false", "0": false
        default: throw .illTyped
        }
    }

    /// ·booleanCanonicalMap·: `true` or `false`.
    public static func representations(of value: Bool) -> [String] {
        [value ? "true" : "false"]
    }
}

extension boolean: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        // Both values are in the value space.
        try! self.init(value)
    }
}

extension Bool: FacetMeasurable {}
