/// Builds an ontology's body, or a declaration's annotations, from a list of
/// declarations.
@resultBuilder
public enum ContentBuilder {
    public static func buildBlock(_ content: any Content...) -> [any Content] {
        content
    }
}
