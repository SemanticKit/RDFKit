import IRIKit

extension IRI {
    /// The IRI that `reference` denotes against `base`: RFC 3986 §5.2
    /// reference resolution, applied where a document's relative references
    /// enter the runtime. `nil` when the target is not an IRI.
    init?(resolving reference: String, against base: String) {
        self.init(rawValue: IRIReferenceComponents(reference).resolved(against: IRIReferenceComponents(base)).string)
    }
}

/// The five components of an IRI reference (RFC 3986 §3), split by the
/// regular expression in Appendix B.
struct IRIReferenceComponents {
    var scheme: Substring?
    var authority: Substring?
    var path: Substring
    var query: Substring?
    var fragment: Substring?

    init(_ reference: String) {
        var rest = Substring(reference)
        if let colon = rest.firstIndex(where: { $0 == ":" || $0 == "/" || $0 == "?" || $0 == "#" }),
           rest[colon] == ":", colon != rest.startIndex {
            scheme = rest[..<colon]
            rest = rest[rest.index(after: colon)...]
        }
        if rest.hasPrefix("//") {
            rest = rest.dropFirst(2)
            let end = rest.firstIndex(where: { $0 == "/" || $0 == "?" || $0 == "#" }) ?? rest.endIndex
            authority = rest[..<end]
            rest = rest[end...]
        }
        if let hash = rest.firstIndex(of: "#") {
            fragment = rest[rest.index(after: hash)...]
            rest = rest[..<hash]
        }
        if let question = rest.firstIndex(of: "?") {
            query = rest[rest.index(after: question)...]
            rest = rest[..<question]
        }
        path = rest
    }

    /// RFC 3986 §5.3 component recomposition.
    var string: String {
        var result = ""
        if let scheme { result += scheme + ":" }
        if let authority { result += "//" + authority }
        result += path
        if let query { result += "?" + query }
        if let fragment { result += "#" + fragment }
        return result
    }

    /// The target of this reference against `base` (RFC 3986 §5.2.2).
    func resolved(against base: IRIReferenceComponents) -> IRIReferenceComponents {
        var target = self
        if scheme != nil {
            target.removeDotSegments()
            return target
        }
        target.scheme = base.scheme
        if authority != nil {
            target.removeDotSegments()
        } else {
            target.authority = base.authority
            if path.isEmpty {
                target.path = base.path
                target.query = query ?? base.query
            } else {
                if !path.hasPrefix("/") { target.path = Substring(base.merged(with: path)) }
                target.removeDotSegments()
            }
        }
        return target
    }

    /// This base's path merged with a relative reference's path (RFC 3986 §5.2.3).
    func merged(with relativePath: Substring) -> String {
        if authority != nil && path.isEmpty {
            return "/" + relativePath
        }
        if let slash = path.lastIndex(of: "/") {
            return String(path[...slash]) + relativePath
        }
        return String(relativePath)
    }

    /// Removes the `.` and `..` segments of the path (RFC 3986 §5.2.4).
    mutating func removeDotSegments() {
        var input = path
        var output: [Substring] = []
        while !input.isEmpty {
            if input.hasPrefix("../") {
                input = input.dropFirst(3)
            } else if input.hasPrefix("./") {
                input = input.dropFirst(2)
            } else if input.hasPrefix("/./") {
                input = input.dropFirst(2)
            } else if input == "/." {
                input = "/"
            } else if input.hasPrefix("/../") {
                input = input.dropFirst(3)
                if !output.isEmpty { output.removeLast() }
            } else if input == "/.." {
                input = "/"
                if !output.isEmpty { output.removeLast() }
            } else if input == "." || input == ".." {
                input = ""
            } else {
                let searchStart = input.hasPrefix("/") ? input.index(after: input.startIndex) : input.startIndex
                let end = input[searchStart...].firstIndex(of: "/") ?? input.endIndex
                output.append(input[..<end])
                input = input[end...]
            }
        }
        path = Substring(output.joined())
    }
}
