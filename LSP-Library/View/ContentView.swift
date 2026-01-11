//
//  ContentView.swift
//  LSP-Library
//
//  Created by Kezia Elice on 09/01/26.
//

import SwiftUI

struct ContentView: View {
    enum Tab { case collections, borrowings }
    
    @State private var selectedTab: Tab? = .collections
    @State private var isAdminLoggedIn = false
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(value: Tab.collections) {
                    Label("Collections", systemImage: "books.vertical")
                }
                
                NavigationLink(value: Tab.borrowings) {
                    Label("Borrowings", systemImage: "list.bullet.rectangle")
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Menu")
            
            Divider()
            
            sidebarFooter
            
        } detail: {
            if let tab = selectedTab {
                switch tab {
                case .collections:
                    CollectionsView()
                case .borrowings:
                    if isAdminLoggedIn {
                        BorrowingsView(onLogout: {
                            isAdminLoggedIn = false
                            selectedTab = .collections
                        })
                    } else {
                        LoginView(onSuccess: {
                            isAdminLoggedIn = true
                            selectedTab = .borrowings
                        })
                    }
                }
            } else {
                Text("Choose Menu")
            }
        }
    }
    
    @ViewBuilder
    private var sidebarFooter: some View {
        if isAdminLoggedIn {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle")
                    Text(SupabaseService.shared.adminUsername ?? "Admin")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Button {
                    SupabaseService.shared.adminId = nil
                    SupabaseService.shared.adminUsername = nil
                    isAdminLoggedIn = false
                    selectedTab = .collections
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .buttonStyle(.borderless)
                .foregroundColor(.red)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


#Preview {
    ContentView()
}
