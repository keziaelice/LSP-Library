//
//  Collection.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//

import Foundation

struct BookCollection: Identifiable, Codable {
    let id_collection: UUID
    let title: String
    let year: String
    let cover_url: String
    let available: Bool
    let created_at: Date?
    
    var id: UUID {id_collection}
}
