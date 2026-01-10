//
//  BorrowingsView.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//

import SwiftUI

struct BorrowingsView: View {
    @StateObject private var vm = BorrowingsViewModel()
    @State private var showNewBorrowing = false

    @State private var searchText: String = ""
    @State private var statusFilter: StatusFilter = .all
    
    let onLogout: () -> Void

    enum StatusFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case borrowed = "Borrowed"
        case returned = "Returned"
        case late = "Late"

        var id: String { rawValue }
    }

    private var filteredRows: [BorrowingDisplay] {
        vm.rows.filter { row in
            let matchesSearch: Bool = {
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
                let q = searchText.lowercased()
                return row.borrower_name.lowercased().contains(q)
                    || row.collection_title.lowercased().contains(q)
                    || row.admin_name.lowercased().contains(q)
            }()

            let matchesStatus: Bool = {
                switch statusFilter {
                case .all: return true
                case .borrowed: return row.status.lowercased() == "borrowed"
                case .returned: return row.status.lowercased() == "returned"
                case .late: return row.status.lowercased() == "late"
                }
            }()

            return matchesSearch && matchesStatus
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            controls

            List(filteredRows) { row in
                BorrowingRowCard(row: row)
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }
            .listStyle(.inset)
        }
        .padding()
        .task { await vm.load() }
    }

    private var header: some View {
        HStack {
            Text("Borrowings")
                .font(.title)

            Spacer()

            Button("New Borrowing") {
                showNewBorrowing = true
            }

            Button("Refresh") {
                Task { await vm.load() }
            }
        }
        .sheet(isPresented: $showNewBorrowing) {
            NewBorrowingSheet(vm: vm)
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            TextField("Search borrower / title / admin", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 320)

            Picker("Status", selection: $statusFilter) {
                ForEach(StatusFilter.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 420)

            Spacer()

            Text("\(filteredRows.count) result(s)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct BorrowingRowCard: View {
    @StateObject private var vm = BorrowingsViewModel()
    let row: BorrowingDisplay

    private var statusText: String { row.status.uppercased() }

    private var statusBadge: some View {
        Text(statusText)
            .font(.caption2)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial)
            .clipShape(Capsule())
    }

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: row.collection_cover_url)) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 8).fill(.quaternary)
            }
            .frame(width: 44, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(row.collection_title)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(row.collection_year)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Admin: \(row.admin_name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text("Borrower: \(row.borrower_name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text("Borrow: \(row.borrow_date)")
                    Text("Due: \(row.due_date)")
                    if let ret = row.return_date, !ret.isEmpty {
                        Text("Return: \(ret)")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer()

            VStack {
                statusBadge
                
                Button("Mark Returned") {
                    Task {
                        await vm.markReturned(
                            idBorrowing: row.id_borrowings,
                            idCollection: row.id_collection
                        )
                    }
                }
                .disabled(vm.isLoading || row.status.lowercased() == "returned")
            }
        }
        .padding(10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
