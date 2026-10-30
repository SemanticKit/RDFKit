import SwiftSyntax

/// An annotation read from a declaration's trailing closure.
struct ParsedAnnotation {
    /// What the annotation was given.
    enum Argument: Equatable {
        /// No argument: `Deprecated()`.
        case none
        /// A string literal's value, with escapes resolved: `Label("Animal")`.
        case text(String)
        /// The related type given as the argument: `Domain(Fauna.Animal)`.
        case term(String)
        /// Any other expression, as source text.
        case expression(String)
    }

    /// The annotation form: `Label`, `Domain`, `SubClassOf`, ...
    let name: String
    let argument: Argument
    /// The authored call, where diagnostics about this annotation point.
    let syntax: Syntax

    /// The term spelling, when the annotation relates to a term.
    var term: String? {
        if case .term(let spelling) = argument { return spelling }
        return nil
    }

    /// The string literal's value, when the annotation carries text.
    var text: String? {
        if case .text(let source) = argument { return source }
        return nil
    }

    /// Whether this annotation states what `other` states: the same form
    /// with the same argument, wherever each was written.
    func states(_ other: ParsedAnnotation) -> Bool {
        name == other.name && argument == other.argument
    }
}
