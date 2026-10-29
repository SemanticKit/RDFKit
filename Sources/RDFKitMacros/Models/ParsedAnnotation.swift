/// An annotation read from a declaration's trailing closure.
struct ParsedAnnotation {
    /// What the annotation was given.
    enum Argument {
        /// No argument: `Deprecated()`.
        case none
        /// A string literal's value, with escapes resolved: `Label("Animal")`.
        case text(String)
        /// A term given as a generic argument: `Domain<Fauna.Animal>()`.
        case term(String)
        /// Any other expression, as source text.
        case expression(String)
    }

    /// The annotation form: `Label`, `Domain`, `SubClassOf`, ...
    let name: String
    let argument: Argument

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
}
