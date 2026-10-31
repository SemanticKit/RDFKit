extension SyntaxError {
    /// An N-Triples document that does not match the RDF 1.2 N-Triples
    /// grammar.
    init(_ error: NTriplesGrammar.SyntaxError) {
        self.init(line: error.location.line, column: error.location.column, message: error.message)
    }

    /// An error at `location` in an N-Triples document.
    init(_ message: String, at location: NTriplesGrammar.Location) {
        self.init(line: location.line, column: location.column, message: message)
    }
}
