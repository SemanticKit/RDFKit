import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct AnnotationResolver {
    static func resolveType(for annotation: ParsedAnnotation) -> String {
        switch annotation.name {
        case "Label", "Comment", "SeeAlso": return "String"
        default: return "IRI"
        }
    }

    static func resolveValue(for annotation: ParsedAnnotation) -> String {
        if annotation.value.hasPrefix("\"") {
            return annotation.value
        }
        return "\"\(annotation.value)\""
    }

    static func propertyName(from annotationName: String) -> String {
        annotationName.prefix(1).lowercased() + annotationName.dropFirst()
    }
}
