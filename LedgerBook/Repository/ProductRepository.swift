//
//  ProductRepository.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/12.
//

import Foundation
import StoreKit

typealias LedgerBookProductsCompletion = ([SKProduct], LedgerBookError?) -> Void

protocol ProductRepositoryProtocol: AnyObject {
    func fetchProductsFromLedgerBookServer()
    func products(productIdentifiers: [String], completion: @escaping LedgerBookProductsCompletion)
}

class ProductRepository: NSObject, ProductRepositoryProtocol, SKProductsRequestDelegate {
    private var ledgerBookProductsCompletion: LedgerBookProductsCompletion?
    
    func fetchProductsFromLedgerBookServer() {
        // TODO
    }
    
    func products(productIdentifiers: [String], completion: @escaping LedgerBookProductsCompletion) {
        self.ledgerBookProductsCompletion = completion
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productRequest.delegate = self
        productRequest.cancel()
        productRequest.start()
    }
    

    // MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count == 0 {
            self.ledgerBookProductsCompletion?([], .emptyProducts)
            self.ledgerBookProductsCompletion = nil
            return
        }
        self.ledgerBookProductsCompletion?(response.products, nil)
    }
}
