//
//  CollectionsViewModel.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//

import Foundation

@MainActor
final class CollectionsViewModel: BaseViewModel {
    @Published var items: [BookCollection] = []

    func load() async {
        do {
            let client = SupabaseService.shared.client

            let response: [BookCollection] = try await client
                .from("COLLECTIONS")
                .select()
                .execute()
                .value

            self.items = response
            print("Loaded \(response.count) collections")

        } catch {
            print("Supabase error:", error)
        }
    }
}
