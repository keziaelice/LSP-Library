//
//  ContentView.swift
//  LSP-Library
//
//  Created by Kezia Elice on 09/01/26.
//

import SwiftUI

struct ContentView: View {
    enum Tab { case catalog, borrowings }

    @State private var selectedTab: Tab = .catalog
    @State private var isAdminLoggedIn = false

    var body: some View {
        TabView(selection: $selectedTab) {
            CollectionsView()
                .tabItem { Label("Catalog", systemImage: "books.vertical") }
                .tag(Tab.catalog)

            borrowingsTab
                .tabItem { Label("Borrowings", systemImage: "list.bullet.rectangle") }
                .tag(Tab.borrowings)
        }
    }

    @ViewBuilder
    private var borrowingsTab: some View {
        if isAdminLoggedIn {
            BorrowingsView(onLogout: { isAdminLoggedIn = false })
        } else {
            LoginView(onSuccess: { isAdminLoggedIn = true })
        }
    }
}

#Preview {
    ContentView()
}
