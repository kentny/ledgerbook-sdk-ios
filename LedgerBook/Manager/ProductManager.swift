//
//  ProductManager.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/29.
//

import Foundation
import StoreKit

class ProductManager: NSObject {
    private let productRepository: ProductRepositoryProtocol
    
    init(_ productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }
    
    func products(productIdentifiers: [String], completion: @escaping ([SKProduct], LedgerBookError?) -> Void) {
        self.productRepository.products(productIdentifiers: productIdentifiers) { skproducts, error in
            completion(skproducts, error)
        }
    }
    
    func products(forceFetch: Bool = false, completion: ([LedgerBookProduct], LedgerBookError?) -> Void) {
        self.productRepository.fetchProductsFromLedgerBookServer()
    }
}
