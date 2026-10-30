extension TurtleGrammar {
    /// What a Turtle document may hold between two terminals, which RDF 1.2
    /// Turtle states in prose rather than in its grammar: white space,
    /// production `WS` (§6.1), and comments, which "start with a # outside
    /// an IRIREF" or string "and continue to the end of line (marked by LF,
    /// or CR), or end of file" (§6.2).
    ///
    /// Returns the offset of the next terminal after `offset`.
    static func trivia(_ scalars: [Unicode.Scalar], from offset: Int) -> Int {
        var index = offset
        while index < scalars.count {
            if let end = WS.longestMatch(in: scalars, at: index), end > index {
                index = end
            } else if scalars[index] == "#" {
                while index < scalars.count, scalars[index] != "\n", scalars[index] != "\r" { index += 1 }
            } else {
                break
            }
        }
        return index
    }
}
