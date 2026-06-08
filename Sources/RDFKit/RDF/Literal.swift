import Foundation

/// An RDF literal with lexical form, optional language tag, text direction, and datatype.
public struct Literal: Object, Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The literal lexical form.
    public let lexicalForm: String

    /// The normalized BCP 47 language tag.
    public let languageTag: String?

    /// The initial text direction for a language-tagged string.
    public let textDirection: TextDirection?

    /// The literal datatype IRI.
    public let datatype: IRI?

    /// Creates an RDF literal.
    public init(
        _ lexicalForm: String,
        languageTag: String? = nil,
        textDirection: TextDirection? = nil,
        datatype: IRI? = nil
    ) throws {
        self.lexicalForm = lexicalForm
        self.languageTag = languageTag?.lowercased()
        self.textDirection = textDirection
        self.datatype = datatype

        if let languageTag = self.languageTag {
            guard !languageTag.isEmpty else {
                throw RDFTermError.emptyLanguageTag
            }
            guard datatype == nil else {
                throw RDFTermError.languageTagWithDatatype
            }
        } else {
            guard textDirection == nil else {
                throw RDFTermError.textDirectionRequiresLanguageTag
            }
        }
    }

    /// A stable RDF literal representation.
    public var description: String {
        var value = "\"\(lexicalForm)\""
        if let languageTag {
            value += "@\(languageTag)"
            if let textDirection {
                value += "--\(textDirection.rawValue)"
            }
        } else if let datatype {
            value += "^^<\(datatype.rawValue)>"
        }
        return value
    }

    /// A debugging representation that includes the type name.
    public var debugDescription: String {
        "Literal(lexicalForm: \(lexicalForm.debugDescription), languageTag: \(String(describing: languageTag)), datatype: \(String(describing: datatype)))"
    }

    public static func < (lhs: Literal, rhs: Literal) -> Bool {
        if lhs.lexicalForm != rhs.lexicalForm { return lhs.lexicalForm < rhs.lexicalForm }
        if lhs.languageTag != rhs.languageTag { return String(describing: lhs.languageTag) < String(describing: rhs.languageTag) }
        if lhs.textDirection != rhs.textDirection { return String(describing: lhs.textDirection) < String(describing: rhs.textDirection) }
        return String(describing: lhs.datatype) < String(describing: rhs.datatype)
    }
}
