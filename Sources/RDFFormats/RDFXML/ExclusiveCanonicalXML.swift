/// Exclusive XML Canonicalization 1.0 with comments and an empty
/// InclusiveNamespaces PrefixList, applied to the content of an
/// `rdf:parseType="Literal"` property element (RDF 1.2 XML Syntax, production
/// parseTypeLiteralPropertyElt).
///
/// The node-set is the element's content: its child elements with their
/// descendants, text, comments and processing instructions. The property
/// element itself is not in the node-set, so the first elements of the
/// content render every namespace declaration they visibly use.
enum ExclusiveCanonicalXML {
    static func serialize(_ items: [XMLInfoset.Item]) -> String {
        var output = ""
        for item in items {
            render(item, rendered: [:], into: &output)
        }
        return output
    }

    /// Renders `item`; `rendered` holds the namespace declarations already
    /// in force from output ancestors, by prefix (`""` for the default).
    private static func render(_ item: XMLInfoset.Item, rendered: [String: String], into output: inout String) {
        switch item {
        case .text(let text):
            output += escapeText(text)
        case .comment(let comment):
            output += "<!--\(comment)-->"
        case .processingInstruction(let target, let data):
            output += data.isEmpty ? "<?\(target)?>" : "<?\(target) \(data)?>"
        case .element(let element):
            render(element, rendered: rendered, into: &output)
        }
    }

    private static func render(_ element: XMLInfoset.Element, rendered: [String: String], into output: inout String) {
        // Exclusive XML Canonicalization: a namespace node is output if the element or one of
        // its attributes visibly utilizes it and an output ancestor has not
        // already rendered it with the same value.
        var utilized: [String: String] = [element.prefix ?? "": element.namespaceName ?? ""]
        for attribute in element.attributes {
            if let prefix = attribute.prefix, prefix != "xml" {
                utilized[prefix] = attribute.namespaceName ?? ""
            }
        }
        var inScope = rendered
        var declarations: [(prefix: String, namespace: String)] = []
        for (prefix, namespace) in utilized {
            let current = rendered[prefix] ?? ""
            if current != namespace {
                declarations.append((prefix, namespace))
                inScope[prefix] = namespace
            }
        }
        declarations.sort { $0.prefix < $1.prefix }

        // Attributes sort by namespace URI, then local name; unqualified
        // attributes have the empty namespace URI and come first.
        let attributes = element.attributes.sorted {
            (($0.namespaceName ?? ""), $0.localName) < (($1.namespaceName ?? ""), $1.localName)
        }

        output += "<" + element.qualifiedName
        for declaration in declarations {
            output += declaration.prefix.isEmpty ? " xmlns=\"" : " xmlns:\(declaration.prefix)=\""
            output += escapeAttribute(declaration.namespace) + "\""
        }
        for attribute in attributes {
            output += " \(attribute.qualifiedName)=\"\(escapeAttribute(attribute.normalizedValue))\""
        }
        output += ">"
        for child in element.children {
            render(child, rendered: inScope, into: &output)
        }
        output += "</\(element.qualifiedName)>"
    }

    /// Canonical XML 1.0, text nodes.
    private static func escapeText(_ text: String) -> String {
        var result = ""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            case "\r": result += "&#xD;"
            default: result.unicodeScalars.append(scalar)
            }
        }
        return result
    }

    /// Canonical XML 1.0, attribute nodes.
    private static func escapeAttribute(_ value: String) -> String {
        var result = ""
        for scalar in value.unicodeScalars {
            switch scalar {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case "\"": result += "&quot;"
            case "\t": result += "&#x9;"
            case "\n": result += "&#xA;"
            case "\r": result += "&#xD;"
            default: result.unicodeScalars.append(scalar)
            }
        }
        return result
    }
}
