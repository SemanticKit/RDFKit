/// A declaration read from an ontology's content.
struct ParsedEntity {
    /// The declaration form that introduced the term.
    enum Kind: String {
        case `class` = "Class"
        case datatype = "Datatype"
        case property = "Property"
        case individual = "Individual"
    }

    /// The local name, the spelling of the generated Swift type.
    let name: String
    let kind: Kind
    let annotations: [ParsedAnnotation]

    /// The term spelling of the first annotation with this form, such as `Domain`.
    func term(_ form: String) -> String? {
        annotations.first { $0.name == form }?.term
    }

    /// Every term spelling given to annotations with this form, such as `SubClassOf`.
    func terms(_ form: String) -> [String] {
        annotations.filter { $0.name == form }.compactMap(\.term)
    }

    /// The string literal source text of the first annotation with this form.
    func text(_ form: String) -> String? {
        annotations.first { $0.name == form }?.text
    }
}
