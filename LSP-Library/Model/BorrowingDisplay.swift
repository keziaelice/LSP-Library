//
//  BorrowingDisplay.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//

import Foundation

struct BorrowingDisplay: Identifiable, Codable {
    let id_borrowings: UUID
    let id_collection: UUID  
    let borrower_name: String
    let borrow_date: String
    let due_date: String
    let return_date: String?
    let status: String

    let admin_name: String
    let collection_title: String
    let collection_year: String
    let collection_cover_url: String

    var id: UUID { id_borrowings }
}
