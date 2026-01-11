//
//  NewBorrowingSheet.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//


import SwiftUI

struct NewBorrowingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: BorrowingsViewModel

    @State private var borrowerName = ""
    @State private var selectedCollectionId: UUID?

    @State private var books: [BookCollection] = []
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Borrowing")
                .font(.title3).bold()

            TextField("Borrower Name", text: $borrowerName)
                .textFieldStyle(.roundedBorder)

            Picker("Book", selection: $selectedCollectionId) {
                Text("Select a book").tag(UUID?.none)

                ForEach(books) { item in
                    Text("\(item.title) (\(item.year))")
                        .tag(UUID?.some(item.id_collection))
                }
            }

            if let errorText {
                Text(errorText)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            HStack {
                Button("Cancel") { dismiss() }

                Spacer()

                Button(isLoading ? "Saving..." : "Save") {
                    Task { await save() }
                }
                .disabled(
                    isLoading ||
                    borrowerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    selectedCollectionId == nil
                )
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(minWidth: 520)
        .task { await loadCollections() }
    }

    // Loads all available book collections from the database.
    // This function only fetches books that are currently not borrowed (available = true) and sorts them alphabetically by title.
    private func loadCollections() async {
        isLoading = true
        errorText = nil

        do {
            let client = SupabaseService.shared.client
            let rows: [BookCollection] = try await client
                .from("COLLECTIONS")
                .select()
                .eq("available", value: true)
                .order("title", ascending: true)
                .execute()
                .value

            books = rows
        } catch {
            errorText = "Failed to load books: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // Saves a new borrowing record to the database.
    // This function creates a new BORROWINGS row, marks the selected book as unavailable, and reloads the available books list
    private func save() async {
        guard let collectionId = selectedCollectionId else { return }

        isLoading = true
        errorText = nil

        let name = borrowerName.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try await vm.createBorrowing(
                borrowerName: name,
                collectionId: collectionId
            )

            await loadCollections()

            dismiss()
        } catch {
            errorText = "Save failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
