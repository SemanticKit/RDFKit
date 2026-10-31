import IRIKit
import RDFCore

/// The decoding of one Turtle document: the triples its statements produce
/// and the state the directives set (RDF 1.2 Turtle §7, Parsing).
///
/// The document's syntax tree comes from the RDF 1.2 Turtle grammar as the
/// specification publishes it (`Grammars/turtle.bnf`), translated by
/// EBNFTranslator into ``TurtleGrammar``. This type gives the productions
/// their actions (§7.4, RDF Term Constructors and Triple Construction); the
/// terms read themselves, each with an initializer on its own type.
struct TurtleDecoding {
    /// The base IRI relative references are resolved against: the
    /// decoder's, until a `BASE` or `@base` directive sets a new one.
    var base: String?
    /// Prefix labels declared by `@prefix` / `PREFIX`, with their namespace
    /// IRI as written after resolution. Keyed by the label's Unicode scalars,
    /// so canonically equivalent labels stay distinct prefixes.
    var namespaces: [[Unicode.Scalar]: String] = [:]
    var blankNodes = BlankNodeLabels()
    var graph: Graph = []

    init(base: String?) {
        self.base = base
    }

    /// `statement ::= directive | triples '.'`
    mutating func read(_ statement: TurtleGrammar.Statement) throws {
        switch statement {
        case .directive(let directive): try read(directive)
        case .triples(let triples): try read(triples)
        }
    }

    /// `directive ::= prefixID | base | version | sparqlPrefix | sparqlBase | sparqlVersion`
    mutating func read(_ directive: TurtleGrammar.Directive) throws {
        switch directive {
        case .prefixID(let prefix): try declare(prefix.pnameNs, as: prefix.iriref)
        case .sparqlPrefix(let prefix): try declare(prefix.pnameNs, as: prefix.iriref)
        case .base(let base): self.base = try IRI(base.iriref, in: self).rawValue
        case .sparqlBase(let base): self.base = try IRI(base.iriref, in: self).rawValue
        case .version, .sparqlVersion: break
        }
    }

    /// Declares the prefix label of `name`, its `PN_PREFIX`, as `iri`.
    mutating func declare(_ name: TurtleGrammar.PNAME_NS, as iri: TurtleGrammar.IRIREF) throws {
        namespaces[Array((name.pnPrefix?.text ?? "").unicodeScalars)] = try IRI(iri, in: self).rawValue
    }

    /// `triples ::= subject predicateObjectList | blankNodePropertyList predicateObjectList? | reifiedTriple predicateObjectList?`
    mutating func read(_ triples: TurtleGrammar.Triples) throws {
        switch triples {
        case .subject(let subject, let list):
            try read(list, subject: SubjectTerm(subject, in: &self))
        case .blankNodePropertyList(let properties, let list):
            let subject = SubjectTerm.blankNode(try BlankNode(properties, in: &self))
            if let list { try read(list, subject: subject) }
        case .reifiedTriple(let triple, let list):
            let subject = try SubjectTerm(triple, in: &self)
            if let list { try read(list, subject: subject) }
        }
    }

    /// `predicateObjectList ::= verb objectList (';' (verb objectList)?)*`
    mutating func read(_ list: TurtleGrammar.PredicateObjectList, subject: SubjectTerm) throws {
        try read(list.objectList, subject: subject, predicate: IRI(list.verb, in: self))
        for case let more? in list.verbAndObjectLists {
            try read(more.objectList, subject: subject, predicate: IRI(more.verb, in: self))
        }
    }

    /// `objectList ::= object annotation (',' object annotation)*`
    mutating func read(_ list: TurtleGrammar.ObjectList, subject: SubjectTerm, predicate: IRI) throws {
        let objects = [(list.object, list.annotation)] + list.objectAndAnnotations.map { ($0.object, $0.annotation) }
        for (object, annotation) in objects {
            let term = try ObjectTerm(object, in: &self)
            emit(subject, predicate, term)
            try read(annotation, of: Graph.Element(subject: subject, predicate: predicate, object: term))
        }
    }

    /// `annotation ::= (reifier | annotationBlock)*`
    ///
    /// Each reifier reifies the triple. An annotation block describes the
    /// reifier just before it, or a fresh blank node reifier when none is
    /// waiting for a block.
    mutating func read(_ annotation: TurtleGrammar.Annotation, of triple: Graph.Element) throws {
        var pending: SubjectTerm?
        for part in annotation.reifierOrAnnotationBlocks {
            switch part {
            case .reifier(let syntax):
                let reifier = try SubjectTerm(syntax, in: &self)
                emit(reifier, .rdfReifies, .tripleTerm(triple))
                pending = reifier
            case .annotationBlock(let block):
                let reifier: SubjectTerm
                if let waiting = pending {
                    reifier = waiting
                } else {
                    reifier = .blankNode(try blankNodes.fresh())
                    emit(reifier, .rdfReifies, .tripleTerm(triple))
                }
                pending = nil
                try read(block.predicateObjectList, subject: reifier)
            }
        }
    }

    mutating func emit(_ subject: SubjectTerm, _ predicate: IRI, _ object: ObjectTerm) {
        graph.insert(Graph.Element(subject: subject, predicate: predicate, object: object))
    }
}
