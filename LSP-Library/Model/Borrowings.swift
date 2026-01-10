//
//  Borrowings.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//

import Foundation

struct Borrowing: Identifiable, Codable {
    let id_borrowings: UUID
    let borrower_name: String
    let id_admin: UUID
    let id_collection: UUID
    let borrow_date: Date
    let due_date: Date
    let return_date: Date?
    let status: String
    let created_at: Date?

    var id: UUID { id_borrowings }
}
