//
//  BorrowingsViewModel.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//

import Foundation

@MainActor
final class BorrowingsViewModel: BaseViewModel {
    @Published var rows: [BorrowingDisplay] = []

    func load() async {
        do {
            let client = SupabaseService.shared.client

            let data: [BorrowingDisplay] = try await client
                .from("view_borrowings_detail")
                .select()
                .order("borrow_date", ascending: false)
                .execute()
                .value

            self.rows = data
            print("Loaded \(data.count) borrowings")
        } catch {
            print("Borrowings view error:", error)
        }
    }
    
    func markReturned(idBorrowing: UUID, idCollection: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            let client = SupabaseService.shared.client

            let today = String(ISO8601DateFormatter().string(from: Date()).prefix(10))

            // 1. Update BORROWINGS
            try await client
                .from("BORROWINGS")
                .update([
                    "status": "returned",
                    "return_date": today
                ])
                .eq("id_borrowings", value: idBorrowing.uuidString)
                .execute()

            // 2. Update COLLECTIONS (set book available again)
            try await client
                .from("COLLECTIONS")
                .update([
                    "available": true
                ])
                .eq("id_collection", value: idCollection.uuidString)
                .execute()

            // 3. Reload from VIEW (not local edit)
            await load()

        } catch {
            errorMessage = error.localizedDescription
            print("Mark returned error:", error)
        }

        isLoading = false
    }
    
    func createBorrowing(
        borrowerName: String,
        collectionId: UUID
    ) async throws {

        guard let adminId = SupabaseService.shared.adminId else {
            throw NSError(domain: "App", code: 401, userInfo: [NSLocalizedDescriptionKey: "Admin not logged in"])
        }

        let client = SupabaseService.shared.client

        _ = try await client
            .from("BORROWINGS")
            .insert([
                "borrower_name": borrowerName,
                "id_admin": adminId.uuidString,
                "id_collection": collectionId.uuidString,
                "status": "borrowed"
            ])
            .execute()

        _ = try await client
            .from("COLLECTIONS")
            .update(["available": false])
            .eq("id_collection", value: collectionId.uuidString)
            .execute()

        await load()
    }
}
