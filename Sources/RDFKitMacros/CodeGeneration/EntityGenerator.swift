import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct EntityGenerator {
    static func generate(
        entity: ParsedEntity,
        ontology: ParsedOntology
    ) -> [DeclSyntax] {
        let typeName = sanitizeIdentifier(entity.name)
        let iri = "\(ontology.namespace)\(entity.name)"

        var metadataProperties: [MetadataProperty] = [
            MetadataProperty(name: "id", typeName: "IRI", value: "\"\(iri)\""),
            MetadataProperty(name: "name", typeName: "String", value: "\"\(entity.name)\""),
        ]

        for ann in entity.annotations {
            guard ann.name != "Deprecated" else { continue }
            let propName = AnnotationResolver.propertyName(from: ann.name)
            let propType = AnnotationResolver.resolveType(for: ann)
            let propValue = AnnotationResolver.resolveValue(for: ann)
            metadataProperties.append(MetadataProperty(name: propName, typeName: propType, value: propValue))
        }

        let supertypes = entity.annotations
            .filter { $0.name == "SubClassOf" }
            .map { $0.value }

        let instanceProperties = ontology.properties.filter { prop in
            let domain = prop.annotationValue(named: "Domain")
            if domain == entity.name { return true }
            if supertypes.contains(domain) { return true }
            return false
        }

        let metadataBlock = MetadataGenerator.generate(properties: metadataProperties)
        let metadataInit = MetadataInitializerGenerator.generate(properties: metadataProperties)
        let storedProperties = InstancePropertyGenerator.generateStoredProperties(properties: instanceProperties)
        let initializer = InstancePropertyGenerator.generateInitializer(properties: instanceProperties)

        let callAsFunctionArgs = metadataProperties.map { prop -> String in
            switch prop.name {
            case "id":
                return "                id: IRI(rawValue: \"\\(Self.metadata.type)\\(name)\") ?? \"\""
            case "name":
                return "                name: name"
            case "label":
                return "                label: name"
            case "comment":
                return "                comment: \"\""
            default:
                return "                \(prop.name): Self.metadata.\(prop.name)"
            }
        }.joined(separator: ",\n")

        let structDecl: DeclSyntax = """
        public struct \(raw: typeName): Entity, Sendable {
            public typealias ID = IRI
        
        \(raw: metadataBlock)
        
        \(raw: metadataInit)
        
        \(raw: storedProperties)
        
        \(raw: initializer)
        
            public static func callAsFunction(
                _ name: String,
                @ContentBuilder _ children: () -> Content
            ) -> Metadata {
                Metadata(
        \(raw: callAsFunctionArgs)
                )
            }
        }
        """

        return [structDecl]
    }

    static func sanitizeIdentifier(_ name: String) -> String {
        var result = name
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        if result == "nil" { result = "nil_" }
        return result
    }
}
