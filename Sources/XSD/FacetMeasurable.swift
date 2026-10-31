/// What the value-based facets measure on a value. A value space that has
/// no measure for a facet gives `nil`, and a definition that uses the facet
/// on it is an error the definition makes, which ``SimpleType`` reports.
public protocol FacetMeasurable: Hashable, Sendable {
    /// The value's length for the length facets (§4.3.1).
    var facetLength: Int? { get }
    /// The order of two values, `nil` when they are incomparable (§4.2.1:
    /// "ordered").
    static func facetOrder(_ lhs: Self, _ rhs: Self) -> FacetOrder?
    /// The numbers of total and of fraction digits (§4.3.11, §4.3.12).
    var facetDigits: (total: Int, fraction: Int)? { get }
    /// Whether the value has a timezone offset (§4.3.14).
    var facetHasTimezone: Bool? { get }
}

/// The order of two values of a value space.
public enum FacetOrder: Sendable {
    case less, equal, greater
}

extension FacetMeasurable {
    public var facetLength: Int? { nil }
    public static func facetOrder(_ lhs: Self, _ rhs: Self) -> FacetOrder? { nil }
    public var facetDigits: (total: Int, fraction: Int)? { nil }
    public var facetHasTimezone: Bool? { nil }
}

extension FacetMeasurable where Self: Comparable {
    public static func facetOrder(_ lhs: Self, _ rhs: Self) -> FacetOrder? {
        lhs < rhs ? .less : lhs == rhs ? .equal : rhs < lhs ? .greater : nil
    }
}
