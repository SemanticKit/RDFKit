import IRIKit

extension IRI: @retroactive Identifiable {
    public var id: IRI { self }
}
