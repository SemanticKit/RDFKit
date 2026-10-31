extension NTriplesGrammar {
    /// What an N-Triples document may hold between two terminals, which RDF
    /// 1.2 N-Triples states in prose rather than in its grammar: "White
    /// space (spaces, and/or tabs) is allowed outside of terminals" (§5.1);
    /// comments start at `#` and "continue to the end of line — marked by
    /// character CR or LF — or to the end of file" (§5.2); and "A blank
    /// line, consisting of only white space and/or a comment, may appear
    /// wherever a triple production is allowed, and are treated as white
    /// space" (§5.1).
    ///
    /// Returns the offset of the next terminal after `offset`.
    static func trivia(_ scalars: [Unicode.Scalar], from offset: Int) -> Int {
        var index = lineSpace(scalars, from: offset)
        // A line end followed by a blank line: the blank line is white space.
        while let end = EOL.longestMatch(in: scalars, at: index), end > index {
            let next = lineSpace(scalars, from: end)
            guard next == scalars.count || EOL.longestMatch(in: scalars, at: next).map({ $0 > next }) == true else { break }
            index = next
        }
        return index
    }

    /// The spaces, tabs and comment from `offset` to the end of the line.
    static func lineSpace(_ scalars: [Unicode.Scalar], from offset: Int) -> Int {
        var index = offset
        while index < scalars.count {
            if scalars[index] == " " || scalars[index] == "\t" {
                index += 1
            } else if scalars[index] == "#" {
                while index < scalars.count, scalars[index] != "\n", scalars[index] != "\r" { index += 1 }
            } else {
                break
            }
        }
        return index
    }
}
