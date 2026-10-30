/// A regular expression of XML Schema 1.1 Part 2 Appendix G, the value of a
/// `pattern` facet: `[\-+]?[0-9]+` for `xsd:integer`, `\i\c*` for
/// `xsd:Name`, `[\i-[:]][\c-[:]]*` for `xsd:NCName`.
///
/// It matches a whole literal (§G.1: "regular expressions ... are
/// implicitly anchored at the head and tail"), character by character,
/// where a character is a Unicode code point.
public struct Pattern: Sendable, Hashable {
    /// The regular expression as the schema document writes it.
    public let expression: String

    private let branches: [[Piece]]

    /// Parses `expression` with the grammar of §G.
    ///
    /// - Precondition: `expression` is a regular expression of §G. The
    ///   patterns come from the translated schema documents.
    public init(_ expression: String) {
        var parser = Parser(Array(expression.unicodeScalars))
        do {
            branches = try parser.parseRegExp()
            guard parser.isAtEnd else { throw Parser.Failure() }
        } catch {
            preconditionFailure("not an XML Schema regular expression: \(expression)")
        }
        self.expression = expression
    }

    public static func == (lhs: Pattern, rhs: Pattern) -> Bool { lhs.expression == rhs.expression }
    public func hash(into hasher: inout Hasher) { hasher.combine(expression) }

    /// Whether the whole of `text` matches.
    public func matches(_ text: String) -> Bool {
        let scalars = Array(text.unicodeScalars)
        return Self.match(branches, scalars, 0) { $0 == scalars.count }
    }

    // MARK: Matching, by backtracking

    private static func match(_ branches: [[Piece]], _ text: [Unicode.Scalar], _ index: Int, _ next: (Int) -> Bool) -> Bool {
        branches.contains { match($0, 0, text, index, next) }
    }

    private static func match(_ pieces: [Piece], _ position: Int, _ text: [Unicode.Scalar], _ index: Int, _ next: (Int) -> Bool) -> Bool {
        guard position < pieces.count else { return next(index) }
        return repeatMatch(pieces[position], 0, text, index) { match(pieces, position + 1, text, $0, next) }
    }

    /// Matches `piece` greedily: one more occurrence when the quantifier
    /// allows it, then the rest of the expression.
    private static func repeatMatch(_ piece: Piece, _ count: Int, _ text: [Unicode.Scalar], _ index: Int, _ next: (Int) -> Bool) -> Bool {
        if piece.maximum.map({ count < $0 }) ?? true {
            let matched = atomMatch(piece.atom, text, index) { end in
                // An occurrence that matches nothing only counts toward the minimum.
                (end != index || count < piece.minimum) && repeatMatch(piece, count + 1, text, end, next)
            }
            if matched { return true }
        }
        return count >= piece.minimum && next(index)
    }

    private static func atomMatch(_ atom: Atom, _ text: [Unicode.Scalar], _ index: Int, _ next: (Int) -> Bool) -> Bool {
        switch atom {
        case .characters(let set):
            return index < text.count && set.contains(text[index]) && next(index + 1)
        case .group(let branches):
            return match(branches, text, index, next)
        }
    }

    // MARK: Syntax (§G.1 to §G.4)

    private struct Piece: Sendable {
        let atom: Atom
        let minimum: Int
        let maximum: Int?
    }

    private indirect enum Atom: Sendable {
        case characters(CharacterSet)
        case group([[Piece]])
    }

    /// A character class (§G.4).
    fileprivate indirect enum CharacterSet: Sendable {
        case ranges([ClosedRange<UInt32>])
        /// A general category, `L` or `Lu` (§G.4.2.4, IsCategory).
        case category(String)
        /// A block escape. A processor that does not recognize the block
        /// name treats it as matching any character (§G.4.2.4), as this one
        /// does.
        case anyCharacter
        case complement(CharacterSet)
        case union([CharacterSet])
        case subtraction(CharacterSet, CharacterSet)

        func contains(_ scalar: Unicode.Scalar) -> Bool {
            switch self {
            case .ranges(let ranges): ranges.contains { $0.contains(scalar.value) }
            case .category(let name): scalar.properties.generalCategory.code.hasPrefix(name)
            case .anyCharacter: true
            case .complement(let set): !set.contains(scalar)
            case .union(let sets): sets.contains { $0.contains(scalar) }
            case .subtraction(let set, let removed): set.contains(scalar) && !removed.contains(scalar)
            }
        }

        static func single(_ scalar: Unicode.Scalar) -> CharacterSet { .ranges([scalar.value...scalar.value]) }

        /// `[^\n\r]`, the wildcard `.` (§G.4.2.5).
        static let wildcard = CharacterSet.complement(.ranges([0xA...0xA, 0xD...0xD]))

        /// `[#x20\t\n\r]`, `\s`.
        static let space = CharacterSet.ranges([0x20...0x20, 0x9...0x9, 0xA...0xA, 0xD...0xD])

        /// `\i`: NameStartChar of XML 1.0 (Fifth Edition) §2.3,
        /// `":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] |
        /// [#xF8-#x2FF] | [#x370-#x37D] | [#x37F-#x1FFF] | [#x200C-#x200D] |
        /// [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] |
        /// [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]`.
        static let nameStart = CharacterSet.ranges([
            0x3A...0x3A, 0x41...0x5A, 0x5F...0x5F, 0x61...0x7A, 0xC0...0xD6, 0xD8...0xF6,
            0xF8...0x2FF, 0x370...0x37D, 0x37F...0x1FFF, 0x200C...0x200D, 0x2070...0x218F,
            0x2C00...0x2FEF, 0x3001...0xD7FF, 0xF900...0xFDCF, 0xFDF0...0xFFFD, 0x10000...0xEFFFF,
        ])

        /// `\c`: NameChar, `NameStartChar | "-" | "." | [0-9] | #xB7 |
        /// [#x0300-#x036F] | [#x203F-#x2040]`.
        static let name = CharacterSet.union([
            nameStart,
            .ranges([0x2D...0x2D, 0x2E...0x2E, 0x30...0x39, 0xB7...0xB7, 0x300...0x36F, 0x203F...0x2040]),
        ])

        /// `\w`: `[#x0000-#x10FFFF]-[\p{P}\p{Z}\p{C}]`.
        static let word = CharacterSet.complement(.union([.category("P"), .category("Z"), .category("C")]))
    }

    private struct Parser {
        struct Failure: Error {}

        private let scalars: [Unicode.Scalar]
        private var index = 0

        init(_ scalars: [Unicode.Scalar]) {
            self.scalars = scalars
        }

        var isAtEnd: Bool { index == scalars.count }
        private var current: Unicode.Scalar? { index < scalars.count ? scalars[index] : nil }

        private mutating func take(_ scalar: Unicode.Scalar) -> Bool {
            guard current == scalar else { return false }
            index += 1
            return true
        }

        /// regExp ::= branch ( '|' branch )*
        mutating func parseRegExp() throws(Failure) -> [[Piece]] {
            var branches = [try parseBranch()]
            while take("|") { branches.append(try parseBranch()) }
            return branches
        }

        /// branch ::= piece*
        private mutating func parseBranch() throws(Failure) -> [Piece] {
            var pieces: [Piece] = []
            while let scalar = current, scalar != "|", scalar != ")" {
                pieces.append(try parsePiece())
            }
            return pieces
        }

        /// piece ::= atom quantifier?
        private mutating func parsePiece() throws(Failure) -> Piece {
            let atom = try parseAtom()
            switch current {
            case "?": index += 1; return Piece(atom: atom, minimum: 0, maximum: 1)
            case "*": index += 1; return Piece(atom: atom, minimum: 0, maximum: nil)
            case "+": index += 1; return Piece(atom: atom, minimum: 1, maximum: nil)
            case "{":
                index += 1
                let minimum = try parseNumber()
                var maximum: Int? = minimum
                if take(",") { maximum = current == "}" ? nil : try parseNumber() }
                guard take("}") else { throw Failure() }
                if let maximum, maximum < minimum { throw Failure() }
                return Piece(atom: atom, minimum: minimum, maximum: maximum)
            default: return Piece(atom: atom, minimum: 1, maximum: 1)
            }
        }

        private mutating func parseNumber() throws(Failure) -> Int {
            var digits = ""
            while let scalar = current, ("0"..."9").contains(scalar) {
                digits.unicodeScalars.append(scalar)
                index += 1
            }
            guard let number = Int(digits) else { throw Failure() }
            return number
        }

        /// atom ::= NormalChar | charClass | ( '(' regExp ')' )
        private mutating func parseAtom() throws(Failure) -> Atom {
            guard let scalar = current else { throw Failure() }
            switch scalar {
            case "(":
                index += 1
                let branches = try parseRegExp()
                guard take(")") else { throw Failure() }
                return .group(branches)
            case "[":
                return .characters(try parseClassExpression())
            case ".":
                index += 1
                return .characters(.wildcard)
            case "\\":
                return .characters(try parseEscape())
            case "?", "*", "+", "{", "}", ")", "|", "]":
                throw Failure()
            default:
                index += 1
                return .characters(.single(scalar))
            }
        }

        /// charClassExpr ::= '[' charGroup ']'; charGroup ::= ( posCharGroup
        /// | negCharGroup ) ( '-' charClassExpr )?
        private mutating func parseClassExpression() throws(Failure) -> CharacterSet {
            guard take("[") else { throw Failure() }
            let negated = take("^")
            var parts: [CharacterSet] = []
            var subtracted: CharacterSet?
            while true {
                guard let scalar = current else { throw Failure() }
                if scalar == "]" {
                    guard !parts.isEmpty else { throw Failure() }
                    index += 1
                    break
                }
                if scalar == "-", index + 1 < scalars.count, scalars[index + 1] == "[" {
                    index += 1
                    subtracted = try parseClassExpression()
                    guard take("]") else { throw Failure() }
                    break
                }
                let start = try parseClassCharacter()
                if case .single(let first)? = start, current == "-", index + 1 < scalars.count, scalars[index + 1] != "]", scalars[index + 1] != "[" {
                    index += 1
                    guard case .single(let last)? = try parseClassCharacter(), first.value <= last.value else { throw Failure() }
                    parts.append(.ranges([first.value...last.value]))
                } else if case .set(let set)? = start {
                    parts.append(set)
                } else if case .single(let scalar)? = start {
                    parts.append(.single(scalar))
                }
            }
            var set = CharacterSet.union(parts)
            if negated { set = .complement(set) }
            if let subtracted { set = .subtraction(set, subtracted) }
            return set
        }

        private enum ClassCharacter {
            case single(Unicode.Scalar)
            case set(CharacterSet)
        }

        /// singleChar or charClassEsc inside a character class.
        private mutating func parseClassCharacter() throws(Failure) -> ClassCharacter? {
            guard let scalar = current else { throw Failure() }
            if scalar == "\\" {
                let escape = try parseEscape()
                if case .ranges(let ranges) = escape, ranges.count == 1, ranges[0].lowerBound == ranges[0].upperBound,
                   let single = Unicode.Scalar(ranges[0].lowerBound) {
                    return .single(single)
                }
                return .set(escape)
            }
            guard scalar != "[" else { throw Failure() }
            index += 1
            return .single(scalar)
        }

        /// SingleCharEsc, MultiCharEsc, catEsc and complEsc (§G.4.2).
        private mutating func parseEscape() throws(Failure) -> CharacterSet {
            guard take("\\"), let scalar = current else { throw Failure() }
            index += 1
            switch scalar {
            case "n": return .single("\n")
            case "r": return .single("\r")
            case "t": return .single("\t")
            case "\\", "|", ".", "?", "*", "+", "(", ")", "{", "}", "-", "[", "]", "^": return .single(scalar)
            case "s": return .space
            case "S": return .complement(.space)
            case "i": return .nameStart
            case "I": return .complement(.nameStart)
            case "c": return .name
            case "C": return .complement(.name)
            case "d": return .category("Nd")
            case "D": return .complement(.category("Nd"))
            case "w": return .word
            case "W": return .complement(.word)
            case "p", "P":
                guard take("{") else { throw Failure() }
                var name = ""
                while let next = current, next != "}" {
                    name.unicodeScalars.append(next)
                    index += 1
                }
                guard take("}"), !name.isEmpty else { throw Failure() }
                let set: CharacterSet = name.hasPrefix("Is") ? .anyCharacter : .category(name)
                return scalar == "p" ? set : .complement(set)
            default: throw Failure()
            }
        }
    }
}

extension Unicode.GeneralCategory {
    /// The category's abbreviation in the Unicode Character Database, as
    /// §G.4.2.4 names categories: `Lu`, `Nd`, `Zs`.
    fileprivate var code: String {
        switch self {
        case .uppercaseLetter: "Lu"
        case .lowercaseLetter: "Ll"
        case .titlecaseLetter: "Lt"
        case .modifierLetter: "Lm"
        case .otherLetter: "Lo"
        case .nonspacingMark: "Mn"
        case .spacingMark: "Mc"
        case .enclosingMark: "Me"
        case .decimalNumber: "Nd"
        case .letterNumber: "Nl"
        case .otherNumber: "No"
        case .connectorPunctuation: "Pc"
        case .dashPunctuation: "Pd"
        case .openPunctuation: "Ps"
        case .closePunctuation: "Pe"
        case .initialPunctuation: "Pi"
        case .finalPunctuation: "Pf"
        case .otherPunctuation: "Po"
        case .mathSymbol: "Sm"
        case .currencySymbol: "Sc"
        case .modifierSymbol: "Sk"
        case .otherSymbol: "So"
        case .spaceSeparator: "Zs"
        case .lineSeparator: "Zl"
        case .paragraphSeparator: "Zp"
        case .control: "Cc"
        case .format: "Cf"
        case .surrogate: "Cs"
        case .privateUse: "Co"
        case .unassigned: "Cn"
        @unknown default: "Cn"
        }
    }
}
