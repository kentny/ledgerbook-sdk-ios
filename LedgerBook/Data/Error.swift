//
//  Error.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/14.
//

import Foundation

public enum LedgerBookError: Error {
    case emptyProducts
    case productsRequestFailure
    case cannotMakePayments
    case billingInProgress
    case restoreInProgress
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
        case .billingInProgress:
            return "Billing process in progress."
        case .restoreInProgress:
            return "Restore process in progress."
        case .unknown:
            return "Unknown error happened."
        }
    }
}
