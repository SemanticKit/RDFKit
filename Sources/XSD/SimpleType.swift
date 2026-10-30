import RDFCore

/// An XML Schema datatype as a Swift value type: its instances are the
/// values of its value space, each built from a lexical form.
///
/// XML Schema 1.1 Part 2 §2.1: "a datatype has a set of distinct values,
/// called its ·value space·, ... a lexical space ... and a lexical-to-value
/// mapping". RDF 1.2 Concepts §5 uses the same three parts for every
/// datatype, and §5.1 names the XSD datatypes RDF uses. The Swift type of
/// each comes from translating the published schema documents: its name,
/// the datatype it is derived from and the facets of its definition. Its
/// primitive gives the value space and the mappings
/// (``PrimitiveDatatype``), which this protocol restricts by the facets.
///
///     let pages = try XSD.nonNegativeInteger(lexicalForm: "212")
///     pages.lexicalForm                                   // "212"
///     try XSD.nonNegativeInteger(lexicalForm: "-1")       // throws: ill-typed
///
/// A value is its datatype's value: two `xsd:decimal` values from `"1.50"`
/// and `"1.5"` are equal, and a value made in Swift writes the canonical
/// form, `"1.5"`. A value decoded from a literal is the value the literal
/// denotes in the property's range, whatever lexical form, and whichever
/// datatype of the range's derivation tree, the literal is written with
/// (`"212"^^xsd:integer` is the `xsd:nonNegativeInteger` 212), and it writes
/// back the literal it was decoded from (``RDFCore/DatatypeValue/literalForm``).
public protocol SimpleType: DatatypeValue, CustomStringConvertible {
    /// The primitive datatype this one is derived from, or itself.
    associatedtype Primitive: PrimitiveDatatype

    /// The value.
    var value: Primitive.Value { get }

    /// The constraining facets the datatype's own definition gives. Those
    /// of the definitions it is derived from apply too (``DerivedDatatype``).
    static var facets: [Facet] { get }

    /// The value a literal of this datatype, or of a datatype derived from
    /// it, denotes, and the form the literal writes it in: the literal's
    /// datatype IRI is the IRI of one of them, and its lexical form is in
    /// that datatype's lexical space. The translated definitions give each
    /// datatype the datatypes derived from it in one step, so the
    /// primitive's denotation searches the whole tree of its derivations.
    static func denotation(inDerivationsOf literal: Literal) -> (value: Primitive.Value, literalForm: LiteralForm)?
}

extension SimpleType {
    /// The lexical-to-value mapping of the datatype (§4.1.4): the literal
    /// is unchanged by the `whiteSpace` normalization, matches the
    /// patterns of each derivation step, is in the primitive's lexical
    /// space, and its value satisfies the value-based facets.
    ///
    /// - Throws: ``RDFCore/DatatypeError/illTyped`` when the literal is not
    ///   in the datatype's lexical space.
    public static func value(lexicalForm: String) throws(DatatypeError) -> Primitive.Value {
        try checkLexical(lexicalForm)
        let value = try Primitive.lexicalMapping(lexicalForm)
        try checkValue(value)
        return value
    }

    /// `value`, when it is in the datatype's value space: it satisfies the
    /// value-based facets and has a lexical representation in the lexical
    /// space (§4.3.4: a pattern restricts the value space to the values
    /// "denoted by" a literal it matches).
    ///
    /// - Throws: ``RDFCore/DatatypeError/illTyped`` otherwise.
    public static func checked(_ value: Primitive.Value) throws(DatatypeError) -> Primitive.Value {
        try checkValue(value)
        guard representation(of: value) != nil else { throw .illTyped }
        return value
    }

    /// The canonical representation of the value in this datatype: the
    /// first of the primitive's representations in the datatype's lexical
    /// space.
    public var lexicalForm: String {
        Self.canonicalLiteralForm(of: value).lexicalForm
    }

    public var description: String { lexicalForm }

    /// The canonical form, with this datatype: how a value made in Swift is
    /// written.
    public static func canonicalLiteralForm(of value: Primitive.Value) -> LiteralForm {
        LiteralForm(lexicalForm: representation(of: value) ?? Primitive.representations(of: value)[0], datatype: datatype)
    }

    /// The value `literal` denotes in this datatype's value space, and the
    /// form it is written in: the literal is of a datatype with the same
    /// primitive (§3.2: the value spaces of the datatypes derived from one
    /// primitive are subsets of the primitive's), well-typed in it, and its
    /// value satisfies this datatype's facets. `nil` for an ill-typed literal,
    /// one of another primitive or of a datatype with no Swift type, and one
    /// whose value is outside this datatype's value space.
    public static func denotation(of literal: Literal) -> (value: Primitive.Value, literalForm: LiteralForm)? {
        guard let denotation = Primitive.denotation(inDerivationsOf: literal),
              let value = try? Self.checked(denotation.value) else { return nil }
        return (value, denotation.literalForm)
    }

    /// The value `literal` denotes when it is a literal of exactly this
    /// datatype: its datatype IRI, derived from ``RDFCore/DatatypeValue/datatype``
    /// for the comparison, is the literal's (RDF 1.2 Concepts §3.2: IRIs are
    /// equal when they are the same sequence of code points), and its
    /// lexical form is in the lexical space.
    public static func ownDenotation(of literal: Literal) -> (value: Primitive.Value, literalForm: LiteralForm)? {
        guard literal.datatypeIRI.rawValue.unicodeScalars.elementsEqual(datatype.stringValue.unicodeScalars),
              let value = try? Self.value(lexicalForm: literal.lexicalForm) else { return nil }
        return (value, LiteralForm(lexicalForm: literal.lexicalForm, datatype: datatype))
    }

    /// The facets of the definitions from the primitive down to this one,
    /// which all apply.
    static var constraints: [Facet] {
        guard let derived = Self.self as? any DerivedDatatype.Type else { return facets }
        return derived.baseConstraints + facets
    }

    /// Values are equal when the datatype's values are: the lexical form a
    /// value was decoded from is how it is written, not what it is.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    private static func representation(of value: Primitive.Value) -> String? {
        Primitive.representations(of: value).first { (try? checkLexical($0)) != nil }
    }

    private static func checkLexical(_ text: String) throws(DatatypeError) {
        for facet in constraints {
            switch facet {
            case .whiteSpace(let whiteSpace):
                guard whiteSpace.normalize(text).unicodeScalars.elementsEqual(text.unicodeScalars) else { throw .illTyped }
            case .pattern(let patterns):
                guard patterns.contains(where: { $0.matches(text) }) else { throw .illTyped }
            default:
                continue
            }
        }
    }

    private static func checkValue(_ value: Primitive.Value) throws(DatatypeError) {
        func bound(_ lexicalForm: String) -> Primitive.Value {
            guard let bound = try? Primitive.lexicalMapping(lexicalForm) else {
                preconditionFailure("The definition of \(Self.datatype.name) gives a bound outside its value space: \(lexicalForm)")
            }
            return bound
        }
        func order(_ other: String) -> FacetOrder? {
            Primitive.Value.facetOrder(value, bound(other))
        }
        func measure<T>(_ measure: T?, _ facet: String) -> T {
            guard let measure else {
                preconditionFailure("The definition of \(Self.datatype.name) uses \(facet), which \(Primitive.datatype.name) values have no measure for")
            }
            return measure
        }
        for facet in constraints {
            let satisfied: Bool
            switch facet {
            case .whiteSpace, .pattern:
                satisfied = true
            case .enumeration(let values):
                satisfied = values.contains { bound($0) == value }
            case .length(let length):
                satisfied = measure(value.facetLength, "length") == length
            case .minLength(let length):
                satisfied = measure(value.facetLength, "minLength") >= length
            case .maxLength(let length):
                satisfied = measure(value.facetLength, "maxLength") <= length
            case .maxInclusive(let bound):
                satisfied = order(bound) == .less || order(bound) == .equal
            case .maxExclusive(let bound):
                satisfied = order(bound) == .less
            case .minInclusive(let bound):
                satisfied = order(bound) == .greater || order(bound) == .equal
            case .minExclusive(let bound):
                satisfied = order(bound) == .greater
            case .totalDigits(let digits):
                satisfied = measure(value.facetDigits, "totalDigits").total <= digits
            case .fractionDigits(let digits):
                satisfied = measure(value.facetDigits, "fractionDigits").fraction <= digits
            case .explicitTimezone(let timezone):
                let hasTimezone = measure(value.facetHasTimezone, "explicitTimezone")
                satisfied = switch timezone {
                case .required: hasTimezone
                case .prohibited: !hasTimezone
                case .optional: true
                }
            }
            guard satisfied else { throw .illTyped }
        }
    }
}
