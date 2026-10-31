import SwiftSyntax
import SwiftSyntaxBuilder

/// Generates what a property declares (D4, D5).
///
/// A property is a requirement on its domain's protocol, typed by its range:
/// `Values<any R>` when it is many-valued, `(any R)?` when it is an
/// `owl:FunctionalProperty`.
///
/// Swift extensions cannot add protocol requirements, so the requirement goes
/// where the macro can write it:
///
/// - When the domain is a class of the same ontology, it is a member of that
///   class's protocol:
///
///       public protocol List: RDFS.Resource {
///           var first: Values<any RDFS.Resource> { get set }
///       }
///
/// - When the domain is the root, or a class of another ontology, the
///   property gets its own protocol in its own ontology, inheriting its domain
///   (`rdfs:domain` entails membership, rdfs2). The class generated for each
///   individual in the domain adopts it:
///
///       public protocol Label: RDFS.Resource {
///           var label: Values<any RDFS.Literal> { get set }
///       }
///
/// A property whose subjects are classes or properties (`rdfs:subClassOf`,
/// `rdfs:domain`) has no stored requirement: classes and properties are
/// Swift types, and the encoder derives those triples from the declarations.
/// `rdf:type` is the individual's conformance to its classes' protocols (D2).
struct PropertyGenerator {
    /// The classes whose members are classes or properties.
    static let schemaDomains: Set<String> = [
        "RDFS.Class", "RDFS.Datatype", "RDF.Property",
        "OWL.Class", "OWL.Restriction", "OWL.DeprecatedClass", "OWL.DataRange",
        "OWL.ObjectProperty", "OWL.DatatypeProperty", "OWL.AnnotationProperty",
        "OWL.OntologyProperty", "OWL.FunctionalProperty", "OWL.DeprecatedProperty",
        "OWL.InverseFunctionalProperty", "OWL.TransitiveProperty", "OWL.SymmetricProperty",
        "OWL.AsymmetricProperty", "OWL.ReflexiveProperty", "OWL.IrreflexiveProperty",
    ]

    /// The root, and the names it goes by (D7).
    static let roots: Set<String> = ["RDFS.Resource", "OWL.Thing"]

    /// Where a property's requirement goes.
    enum Placement {
        /// No stored requirement.
        case none
        /// A member of the protocol of the named class of the same ontology.
        case member(of: String)
        /// The property's own protocol, inheriting its domain.
        case ownProtocol(domain: String)
    }

    static func placement(of property: ParsedEntity, in ontology: ParsedOntology) -> Placement {
        let domain = property.annotationValue(named: "Domain")
        if ontology.namespace == ClassGenerator.rdf && property.name == "type" { return .none }
        if schemaDomains.contains(domain) { return .none }
        if domain.isEmpty || roots.contains(domain) { return .ownProtocol(domain: "RDFS.Resource") }
        let local = domain.hasPrefix("\(ontology.name).") ? String(domain.dropFirst(ontology.name.count + 1)) : domain
        if !local.contains("."), ontology.classes.contains(where: { $0.name == local }) {
            return .member(of: local)
        }
        return .ownProtocol(domain: domain)
    }

    /// The requirements that go in a class's protocol.
    static func requirements(of entity: ParsedEntity, in ontology: ParsedOntology) -> [DeclSyntax] {
        ontology.properties.compactMap { property in
            guard case .member(let owner) = placement(of: property, in: ontology), owner == entity.name else { return nil }
            return DeclSyntax(requirement(for: property))
        }
    }

    /// The protocol a property declares when its domain is the root or in
    /// another ontology.
    static func generate(property: ParsedEntity, in ontology: ParsedOntology) -> DeclSyntax? {
        guard case .ownProtocol(let domain) = placement(of: property, in: ontology) else { return nil }
        let name = property.name.prefix(1).uppercased() + property.name.dropFirst()
        return DeclSyntax(ProtocolDeclSyntax(
            leadingTrivia: ClassGenerator.documentation(of: property),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            name: .identifier(name),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax(stringLiteral: domain))
            },
            memberBlock: MemberBlockSyntax {
                requirement(for: property)
            }
        ))
    }

    /// `var first: Values<any RDFS.Resource> { get set }`.
    static func requirement(for property: ParsedEntity) -> VariableDeclSyntax {
        VariableDeclSyntax(
            leadingTrivia: ClassGenerator.documentation(of: property),
            bindingSpecifier: .keyword(.var),
            bindings: [PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier(property.name)),
                typeAnnotation: TypeAnnotationSyntax(type: valueType(of: property)),
                accessorBlock: AccessorBlockSyntax(accessors: .accessors([
                    AccessorDeclSyntax(accessorSpecifier: .keyword(.get)),
                    AccessorDeclSyntax(accessorSpecifier: .keyword(.set)),
                ]))
            )]
        )
    }

    /// The Swift type of a property's values: its range as an existential,
    /// in `Values` or, for a functional property, an `Optional`.
    static func valueType(of property: ParsedEntity) -> TypeSyntax {
        let range = property.annotationValue(named: "Range")
        let element = range.isEmpty ? "any RDFS.Resource" : "any \(range)"
        let isFunctional = property.annotations.contains { $0.name == "Type" && $0.value == "OWL.FunctionalProperty" }
        return isFunctional ? TypeSyntax("(\(raw: element))?") : TypeSyntax("Values<\(raw: element)>")
    }
}
