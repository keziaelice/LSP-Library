//
//  ChipRenderable.swift
//  LSP-Library
//
//  Created by Kezia Elice on 11/01/26.
//


import Foundation

// Protocol that defines the data contract for date capsules
protocol Capsules {
    var label: String { get }
    var value: String { get }
}

struct BorrowCapsule: Capsules {
    let value: String
    var label: String { "Borrow" }
}

struct DueCapsule: Capsules {
    let value: String
    var label: String { "Due" }
}

struct ReturnCapsule: Capsules {
    let value: String
    var label: String { "Return" }
}
