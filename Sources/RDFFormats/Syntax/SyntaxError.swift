/// A document that does not match its format's grammar.
public struct SyntaxError: Error, Equatable, Sendable, CustomStringConvertible {
    /// The 1-based line where the error was found.
    public let line: Int

    /// The 1-based column, counted in Unicode scalars, where the error was found.
    public let column: Int

    /// What the decoder expected or rejected.
    public let message: String

    /// Creates a syntax error.
    public init(line: Int, column: Int, message: String) {
        self.line = line
        self.column = column
        self.message = message
    }

    public var description: String { "\(line):\(column): \(message)" }
}
