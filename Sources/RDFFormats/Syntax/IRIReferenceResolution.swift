import IRIKit

/// RFC 3986 §5.2 reference resolution, applied where a document's relative
/// IRI references enter the runtime.
struct IRIReferenceResolution {
    /// The five components of RFC 3986 §3, split by the regular expression in
    /// Appendix B.
    struct Components {
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
    }

    /// Resolves `reference` against `base` (RFC 3986 §5.2.2).
    static func resolve(_ reference: String, against base: String) -> String {
        let r = Components(reference)
        if r.scheme != nil {
            var target = r
            target.path = Substring(removeDotSegments(r.path))
            return target.string
        }
        let b = Components(base)
        var target = r
        target.scheme = b.scheme
        if r.authority != nil {
            target.path = Substring(removeDotSegments(r.path))
        } else {
            target.authority = b.authority
            if r.path.isEmpty {
                target.path = b.path
                target.query = r.query ?? b.query
            } else if r.path.hasPrefix("/") {
                target.path = Substring(removeDotSegments(r.path))
            } else {
                target.path = Substring(removeDotSegments(Substring(merge(base: b, path: r.path))))
            }
        }
        return target.string
    }

    /// RFC 3986 §5.2.3.
    static func merge(base: Components, path: Substring) -> String {
        if base.authority != nil && base.path.isEmpty {
            return "/" + path
        }
        if let slash = base.path.lastIndex(of: "/") {
            return String(base.path[...slash]) + path
        }
        return String(path)
    }

    /// RFC 3986 §5.2.4.
    static func removeDotSegments(_ path: Substring) -> String {
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
        return output.joined()
    }
}
