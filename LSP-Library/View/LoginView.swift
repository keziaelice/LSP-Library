//
//  LoginView.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//


import SwiftUI

struct LoginView: View {
    let onSuccess: () -> Void
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 14) {
            Text("Admin Login")
                .font(.title2).bold()

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)

            if let errorText {
                Text(errorText).foregroundStyle(.red).font(.caption)
            }

            Button("Login") {
                print("LOGIN BUTTON TAPPED")
                Task { await login() }
            }
            .keyboardShortcut(.defaultAction)

        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 260)
    }

    private func login() async {
        print("LOGIN STARTED")
        errorText = nil

        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        if u.isEmpty || password.isEmpty {
            errorText = "Username and password are required."
            return
        }
        
        print("Username:", u)
        print("Password:", password)

        do {
            struct AdminRow: Decodable {
                let id_admin: UUID
                let username: String
            }

            let client = SupabaseService.shared.client
            let rows: [AdminRow] = try await client
                .rpc("admin_login", params: [
                    "p_username": u,
                    "p_password": password
                ])
                .execute()
                .value
            
            print("RPC returned:", rows)
            
            if let admin = rows.first {
                print("LOGIN SUCCESS:", admin.username)
                SupabaseService.shared.adminId = admin.id_admin
                SupabaseService.shared.adminUsername = admin.username
                onSuccess()
            } else {
                errorText = "Invalid username or password."
            }
        } catch {
            errorText = "Login error: \(error)"
            print("Login RPC error:", error)
        }
    }
}
