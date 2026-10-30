extension SyntaxError {
    /// A Turtle document that does not match the RDF 1.2 Turtle grammar.
    init(_ error: TurtleGrammar.SyntaxError) {
        self.init(line: error.location.line, column: error.location.column, message: error.message)
    }

    /// An error at `location` in a Turtle document.
    init(_ message: String, at location: TurtleGrammar.Location) {
        self.init(line: location.line, column: location.column, message: message)
    }
}
