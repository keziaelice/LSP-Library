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
                Spacer()
                Button("Refresh") {
                    Task { await vm.load() }
                }
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
    }
}

private struct BookCard: View {
    let item: BookCollection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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

            Text(item.title)
                .font(.headline)
                .lineLimit(2)
                .frame(height: 44, alignment: .top)

            HStack {
                Text(item.year)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(item.available ? "Available" : "Unavailable")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.available ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                    .clipShape(Capsule())
            }
            .frame(height: 5)
        }
        .padding(10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    CollectionsView()
}
