import Foundation

/// Renders expanded ontology declarations as Swift source.
struct OntologyExpansionSourceRenderer: Sendable {
    /// The access level emitted for generated declarations.
    let access: OntologyExpansion.Access

    /// The expression emitted for each generated term's owning ontology.
    let ontologyExpression: String

    /// Returns Swift source for declarations.
    func source(for declarations: [OntologyExpansionDeclaration]) throws -> String {
        try declarations.map(source(for:)).joined(separator: "\n\n")
    }

    /// Returns nested Swift source for declarations owned by a vocabulary type.
    func vocabularySource(for declarations: [OntologyExpansionDeclaration], vocabularyName: String) throws -> String {
        let body = try declarations
            .map { try vocabularyDeclarationSource(for: $0, vocabularyName: vocabularyName) }
            .joined(separator: "\n\n")

        return """
        \(access.keyword) extension \(vocabularyName) {
        \(indent(body))
        }
        """
    }

    /// Returns Swift source for one expanded declaration.
    private func source(for declaration: OntologyExpansionDeclaration) throws -> String {
        let typeName = try swiftTypeName(for: declaration.localName)
        let localName = escapedSwiftString(declaration.localName.rawValue)
        let keyword = access.keyword

        return """
        \(keyword) struct \(typeName): OntologyScopedTerm, \(roleProtocol(for: declaration.role)) {
            \(keyword) static let ontology = \(ontologyExpression)
            \(keyword) static let localName = LocalName("\(localName)")

            \(keyword) let value: String

            \(keyword) init() {
                self.value = ""
            }

            \(keyword) init(_ value: String) {
                self.value = value
            }
        }
        """
    }

    /// Returns Swift source for one nested vocabulary declaration.
    private func vocabularyDeclarationSource(
        for declaration: OntologyExpansionDeclaration,
        vocabularyName: String
    ) throws -> String {
        let typeName = try swiftTypeName(for: declaration.localName)
        let localName = escapedSwiftString(declaration.localName.rawValue)
        let keyword = access.keyword
        let termProtocol = termProtocolName(for: declaration.localName, vocabularyName: vocabularyName)
        let conformanceList = vocabularyConformanceList(for: declaration, termProtocol: termProtocol)
        let prefix = vocabularyName.lowercased()
        let localNameDeclaration = explicitLocalNameNeeded(typeName: typeName, localName: declaration.localName) ?
            "\n\n    \(keyword) static let localName = LocalName(\"\(localName)\")" :
            ""
        let staticAccessor = staticAccessorSource(typeName: typeName, localName: declaration.localName, keyword: keyword)
        let factDeclarations = vocabularyFactDeclarations(for: declaration.facts, keyword: keyword)

        return """
        /// \(prefix):\(declaration.localName.rawValue).
        \(staticAccessor)

        /// \(prefix):\(declaration.localName.rawValue).
        \(keyword) struct \(typeName): \(conformanceList) {\(localNameDeclaration)\(factDeclarations)
            /// Creates a \(prefix):\(declaration.localName.rawValue) term value.
            \(keyword) init() {}
        }
        """
    }

    /// Returns the Swift role protocol for an ontology declaration role.
    private func roleProtocol(for role: OntologyDeclarationRole) -> String {
        switch role {
        case .class:
            "RDFClass"
        case .property:
            "RDFProperty"
        case .datatype:
            "RDFDatatype"
        case .individual:
            "RDFIndividual"
        }
    }

    /// Returns all Swift protocols a generated vocabulary declaration should conform to.
    private func vocabularyConformanceList(
        for declaration: OntologyExpansionDeclaration,
        termProtocol: String
    ) -> String {
        var protocols = ["RDFKit.\(roleProtocol(for: declaration.role))", termProtocol]

        if declaration.role == .property {
            protocols.append(contentsOf: propertyProtocols(for: declaration.facts))
        }
        protocols.append(contentsOf: metadataProtocols(for: declaration.facts))

        return protocols.joined(separator: ", ")
    }

    /// Returns metadata protocols inferred from declaration facts.
    private func metadataProtocols(for facts: OntologyDeclarationFacts) -> [String] {
        var protocols: [String] = []

        if facts.labels.isEmpty == false {
            protocols.append("LabeledTerm")
        }
        if facts.comments.isEmpty == false {
            protocols.append("CommentedTerm")
        }
        if facts.deprecated != nil {
            protocols.append("DeprecatedTerm")
        }

        return protocols
    }

    /// Returns property-specific protocols inferred from declaration facts.
    private func propertyProtocols(for facts: OntologyDeclarationFacts) -> [String] {
        var protocols: [String] = []

        if facts.types.contains(OWL.ObjectProperty.iri) {
            protocols.append("RDFKit.ObjectProperty")
        } else if facts.types.contains(OWL.DatatypeProperty.iri) {
            protocols.append("RDFKit.DatatypeProperty")
        } else if facts.types.contains(OWL.AnnotationProperty.iri) {
            protocols.append("RDFKit.AnnotationProperty")
        } else if facts.types.contains(OWL.OntologyProperty.iri) {
            protocols.append("RDFKit.OntologyProperty")
        } else {
            protocols.append("RelationshipProperty")
        }

        if facts.types.contains(OWL.AnnotationProperty.iri) && protocols.contains("RDFKit.AnnotationProperty") == false {
            protocols.append("RDFKit.AnnotationProperty")
        }
        if facts.types.contains(OWL.OntologyProperty.iri) && protocols.contains("RDFKit.OntologyProperty") == false {
            protocols.append("RDFKit.OntologyProperty")
        }
        if facts.domains.isEmpty == false {
            protocols.append("DomainConstrainedProperty")
        }
        if facts.ranges.isEmpty == false {
            protocols.append("RangeConstrainedProperty")
        }
        if facts.superproperties.isEmpty == false {
            protocols.append("SubpropertyAwareProperty")
        }

        return protocols
    }

    /// Returns stored fact declarations for generated constrained properties.
    private func vocabularyFactDeclarations(for facts: OntologyDeclarationFacts, keyword: String) -> String {
        var declarations: [String] = []

        if facts.labels.isEmpty == false {
            declarations.append("""

                /// The rdfs:label values declared for this term.
                \(keyword) static let labels: [String] = \(stringArraySource(facts.labels))
            """)
        }
        if facts.comments.isEmpty == false {
            declarations.append("""

                /// The rdfs:comment values declared for this term.
                \(keyword) static let comments: [String] = \(stringArraySource(facts.comments))
            """)
        }
        if let deprecated = facts.deprecated {
            declarations.append("""

                /// Whether this term is declared owl:deprecated.
                \(keyword) static let deprecated = \(deprecated)
            """)
        }
        if facts.domains.isEmpty == false {
            declarations.append("""

                /// The rdfs:domain values declared for this term.
                \(keyword) static let domains: [IRI] = \(iriArraySource(facts.domains))
            """)
        }
        if facts.ranges.isEmpty == false {
            declarations.append("""

                /// The rdfs:range values declared for this term.
                \(keyword) static let ranges: [IRI] = \(iriArraySource(facts.ranges))
            """)
        }
        if facts.superproperties.isEmpty == false {
            declarations.append("""

                /// The rdfs:subPropertyOf values declared for this term.
                \(keyword) static let superproperties: [IRI] = \(iriArraySource(facts.superproperties))
            """)
        }

        return declarations.joined()
    }

    /// Returns Swift source for an IRI array literal.
    private func iriArraySource(_ iris: Set<IRI>) -> String {
        let values = iris.sorted().map { "IRI(\"\(escapedSwiftString($0.rawValue))\")" }
        return "[\(values.joined(separator: ", "))]"
    }

    /// Returns Swift source for a string array literal.
    private func stringArraySource(_ values: Set<String>) -> String {
        let values = values.sorted().map { "\"\(escapedSwiftString($0))\"" }
        return "[\(values.joined(separator: ", "))]"
    }

    /// Returns the vocabulary term protocol used for a declaration.
    private func termProtocolName(for localName: LocalName, vocabularyName: String) -> String {
        if lowerCamelName(localName.rawValue) {
            "\(vocabularyName)LowerCamelTerm"
        } else {
            "\(vocabularyName)Term"
        }
    }

    /// Returns a static accessor for lower-camel vocabulary terms.
    private func staticAccessorSource(typeName: String, localName: LocalName, keyword: String) -> String {
        guard lowerCamelName(localName.rawValue) else { return "" }

        return """
        \(keyword) static var \(localName.rawValue): \(typeName) { \(typeName)() }
        """
    }

    /// Returns a Swift type identifier for an RDF local name.
    private func swiftTypeName(for localName: LocalName) throws -> String {
        if localName.rawValue == "type" {
            return "TypeTerm"
        }

        let pieces = localName.rawValue.unicodeScalars
            .split { CharacterSet.alphanumerics.contains($0) == false }
            .map { upperCamel(String($0)) }
        var typeName = pieces.joined()

        if let first = typeName.unicodeScalars.first, CharacterSet.decimalDigits.contains(first) {
            typeName = "Term" + typeName
        }

        guard isSwiftTypeIdentifier(typeName) else {
            throw OntologyExpansion.Failure.invalidSwiftTypeName(localName.rawValue)
        }

        return typeName
    }

    /// Returns whether the local name is authored in lower camel case.
    private func lowerCamelName(_ localName: String) -> Bool {
        guard let first = localName.unicodeScalars.first else { return false }
        return CharacterSet.lowercaseLetters.contains(first)
    }

    /// Returns whether the generated declaration must explicitly preserve its RDF local name.
    private func explicitLocalNameNeeded(typeName: String, localName: LocalName) -> Bool {
        typeName != localName.rawValue
    }

    /// Indents generated source for nesting inside another declaration.
    private func indent(_ source: String) -> String {
        source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.isEmpty ? "" : "    " + $0 }
            .joined(separator: "\n")
    }

    /// Converts one identifier component to UpperCamel case.
    private func upperCamel(_ value: String) -> String {
        guard let first = value.first else { return "" }
        return String(first).uppercased() + value.dropFirst()
    }

    /// Returns whether text is a valid Swift type identifier.
    private func isSwiftTypeIdentifier(_ value: String) -> Bool {
        guard let first = value.unicodeScalars.first else { return false }
        guard CharacterSet.letters.contains(first) || first == "_" else { return false }

        return value.unicodeScalars.dropFirst().allSatisfy {
            CharacterSet.alphanumerics.contains($0) || $0 == "_"
        }
    }

    /// Escapes text for a Swift string literal.
    private func escapedSwiftString(_ value: String) -> String {
        var escaped = ""

        for character in value {
            switch character {
            case "\\":
                escaped += "\\\\"
            case "\"":
                escaped += "\\\""
            case "\n":
                escaped += "\\n"
            case "\r":
                escaped += "\\r"
            case "\t":
                escaped += "\\t"
            default:
                escaped.append(character)
            }
        }

        return escaped
    }
}
