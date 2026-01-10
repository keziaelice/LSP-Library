//
//  SupabaseService.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    var adminId: UUID?
    var adminUsername: String?

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }
    
    func logout() {
        adminId = nil
        adminUsername = nil
    }
}
