import IRIKit
import RDFCore

extension Literal {
    /// The literal a Turtle `NumericLiteral` or `BooleanLiteral` token
    /// stands for (RDF 1.2 Turtle §2.5.2, §7.4): `INTEGER`, `DECIMAL` and
    /// `DOUBLE` with their XML Schema datatypes, `true` and `false` as
    /// `xsd:boolean`. `nil` for any other token.
    init?(_ token: TurtleToken) {
        let datatype: IRI
        let text: String
        switch token {
        case .integer(let lexicalForm): (datatype, text) = (.xsdInteger, lexicalForm)
        case .decimal(let lexicalForm): (datatype, text) = (.xsdDecimal, lexicalForm)
        case .double(let lexicalForm): (datatype, text) = (.xsdDouble, lexicalForm)
        case .word("true"): (datatype, text) = (.xsdBoolean, "true")
        case .word("false"): (datatype, text) = (.xsdBoolean, "false")
        default: return nil
        }
        self.init(text, datatype: datatype)
    }

    /// The lexical form itself, when Turtle reads it back as this literal
    /// (RDF 1.2 Turtle §2.5.2): `INTEGER`, `DECIMAL` and `DOUBLE` with their
    /// XML Schema datatypes, and `true` and `false` as `xsd:boolean`.
    var turtleShortForm: String? {
        guard let datatype else { return nil }
        let matches: Bool
        switch datatype {
        case .xsdInteger: matches = lexicalForm.wholeMatch(of: #/[+-]?[0-9]+/#) != nil
        case .xsdDecimal: matches = lexicalForm.wholeMatch(of: #/[+-]?[0-9]*\.[0-9]+/#) != nil
        case .xsdDouble: matches = lexicalForm.wholeMatch(of: #/[+-]?(?:[0-9]+\.[0-9]*|\.?[0-9]+)[eE][+-]?[0-9]+/#) != nil
        case .xsdBoolean: matches = lexicalForm == "true" || lexicalForm == "false"
        default: matches = false
        }
        return matches ? lexicalForm : nil
    }
}
