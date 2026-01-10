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
                BorrowingRowCard(vm: vm, row: row)
                    .padding(.vertical, 6)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                    .listRowBackground(Color.clear)
            }
            .listStyle(.inset)
        }
        .padding()
        .task { await vm.load() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await vm.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh")
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("Borrowings")
                .font(.title2).bold()
            
            Spacer()
            
            Button("New Borrowing") {
                showNewBorrowing = true
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
    @ObservedObject var vm: BorrowingsViewModel
    let row: BorrowingDisplay

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            AsyncImage(url: URL(string: row.collection_cover_url)) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 8).fill(.quaternary)
            }
            .frame(width: 70, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.collection_title)
                        .font(.headline)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text("Borrower: \(row.borrower_name)")
                        Text("|")
                        Text("Admin: \(row.admin_name)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                HStack(spacing: 8) {
                    dateCapsule(label: "BORROW", date: row.borrow_date)
                    
                    dateCapsule(label: "DUE", date: row.due_date)

                    if let ret = row.return_date, !ret.isEmpty {
                        dateCapsule(label: "RETURNED", date: ret)
                    }
                }
                .padding(.top, 4)
            }

            Spacer()
            
            if row.status.lowercased() != "returned" {
                Button("Mark as Returned") {
                    Task {
                        await vm.markReturned(
                            idBorrowing: row.id_borrowings,
                            idCollection: row.id_collection
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .controlSize(.regular)
                .disabled(vm.isLoading)
            }
        }
        .padding(15)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    @ViewBuilder
    private func dateCapsule(label: String, date: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            HStack(spacing: 6) {
                Text(date)
                    .font(.system(size: 11, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(0.08))
            .clipShape(Capsule())
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}
