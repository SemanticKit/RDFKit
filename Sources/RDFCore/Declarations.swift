public enum ClassDeclaration {}
public enum DatatypeDeclaration {}
public enum IndividualDeclaration {}
public enum PropertyDeclaration {}
public enum TypeDeclaration {}
public enum DomainDeclaration {}
public enum RangeDeclaration {}
public enum SeeAlsoDeclaration {}
public enum SubClassOfDeclaration {}
public enum SubPropertyOfDeclaration {}
public enum IsDefinedByDeclaration {}
public enum LabelDeclaration {}
public enum CommentDeclaration {}
public enum OWLDeprecatedDeclaration {}
public enum AnnotationDeclaration {}

public typealias Class<Body: Content> = NamedDeclaration<ClassDeclaration, Body>
public typealias Datatype<Body: Content> = NamedDeclaration<DatatypeDeclaration, Body>
public typealias Individual<Body: Content> = NamedDeclaration<IndividualDeclaration, Body>
public typealias Property<Body: Content> = NamedDeclaration<PropertyDeclaration, Body>

public typealias Type = IRIAssertion<TypeDeclaration>
public typealias Domain = IRIAssertion<DomainDeclaration>
public typealias Range = IRIAssertion<RangeDeclaration>
public typealias SeeAlso = IRIAssertion<SeeAlsoDeclaration>
public typealias SubClassOf = IRIAssertion<SubClassOfDeclaration>
public typealias SubPropertyOf = IRIAssertion<SubPropertyOfDeclaration>
public typealias IsDefinedBy = IRIAssertion<IsDefinedByDeclaration>

public typealias Label = TextAssertion<LabelDeclaration>
public typealias Comment = TextAssertion<CommentDeclaration>
public typealias OWLDeprecated = BooleanAssertion<OWLDeprecatedDeclaration>
public typealias Annotation<Body: Content> = BlockDeclaration<AnnotationDeclaration, Body>
