//
//  BaseViewModel.swift
//  LSP-Library
//
//  Created by Kezia Elice on 10/01/26.
//


import Foundation

@MainActor
class BaseViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func startLoading() {
        isLoading = true
        errorMessage = nil
    }

    func stopLoading() {
        isLoading = false
    }

    func setError(_ error: Error) {
        errorMessage = error.localizedDescription
        stopLoading()
    }
}