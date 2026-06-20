import Foundation

/// A term that declares a superproperty.
///
/// The macro generates this conformance when `SubPropertyOf(...)` appears
/// in the DSL body.
//public protocol SubPropertyOfTerm: OntologyTerm {}
//
//extension SubPropertyOfTerm {
//    public var subPropertyOf: (any Node)? {
//        children.lazy
//            .compactMap { $0 as? SubPropertyOfAnnotationValue }
//            .first?.term
//    }
//}
