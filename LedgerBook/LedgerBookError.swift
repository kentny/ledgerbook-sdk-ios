//
//  LedgerBookError.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/14.
//

import Foundation

public enum LedgerBookError: Error {
    case emptyProducts
    case productsRequestFailure
    case unknown(code: Int)
}

extension LedgerBookError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyProducts:
             return "No Product information."
        case .productsRequestFailure:
            return "Failed to request products information."
        case .unknown(let code):
            return "Unknown error happened. (Code: \(code))"
        }
    }
}
