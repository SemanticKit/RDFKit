import Foundation

/// A term that declares a range.
///
/// The macro generates this conformance when `Range(...)` appears
/// in the DSL body.
//public protocol RangeTerm: OntologyTerm {}
//
//extension RangeTerm {
//    public var range: (any Node)? {
//        children.lazy
//            .compactMap { $0 as? RangeAnnotationValue }
//            .first?.term
//    }
//}
