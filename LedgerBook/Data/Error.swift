//
//  Error.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/14.
//

import Foundation
import StoreKit

public enum LedgerBookError: Error {
    case emptyProducts
    case productsRequestFailure
    case cannotMakePayments
    case purchaseInProgress
    case restoreInProgress
    case transactionFailure(SKError)
    case unknown
}

extension LedgerBookError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyProducts:
             return "No Product information."
        case .productsRequestFailure:
            return "Failed to request products information."
        case .cannotMakePayments:
            return "Purchase has been disabled in the settings."
        case .purchaseInProgress:
            return "Purchase process in progress."
        case .restoreInProgress:
            return "Restore process in progress."
        case .unknown:
            return "Unknown error happened."
        case .transactionFailure(let skerror):
            return "Transaction failure. (\(skerror.localizedDescription)"
        }
    }
}
