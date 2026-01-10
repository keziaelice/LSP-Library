//
//  CollectionsView.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//

import SwiftUI

struct CollectionsView: View {
    @StateObject private var vm = CollectionsViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Collections")
                    .font(.title2).bold()
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(vm.items) { item in
                        BookCard(item: item)
                    }
                }
                .padding(.vertical, 8)
            }
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
}

private struct BookCard: View {
    let item: BookCollection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: item.cover_url)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.quaternary)
                    ProgressView()
                }
            }
            .frame(height: 190)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                    .frame(height: 40, alignment: .topLeading)

                HStack {
                    Text(item.year)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(item.available ? "Available" : "Unavailable")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.available ? Color.green.opacity(0.15) : Color.secondary.opacity(0.15))
                        .foregroundStyle(item.available ? .green : .secondary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.03))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    CollectionsView()
}
