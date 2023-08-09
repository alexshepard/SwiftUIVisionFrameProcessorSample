//
//  Taxonomy.swift
//  ComputerVisionSampleApp
//
//  Created by Alex Shepard on 8/8/23.
//

import Foundation

public class TTaxonomy {
    private var taxa = [TTaxon]()
    public var leafClassIdToTax = [Int: TTaxon]()

    public func loadTaxonomy(taxUrl: URL) throws {
        let data = try Data(contentsOf: taxUrl)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.taxa = try decoder.decode([TTaxon].self, from: data)
        for taxon in taxa {
            if let leafClassId = taxon.leafClassId {
                leafClassIdToTax[leafClassId] = taxon
            }
        }
    }
}

public class TTaxon: Codable {
    var parentTaxonId: Int?
    let taxonId: Int
    let rankLevel: Float
    var leafClassId: Int?
    var iconicClassId: Int?
    let name: String
}
