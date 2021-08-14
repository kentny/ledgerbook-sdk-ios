//
//  LedgerBook.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/08.
//

import Foundation
import StoreKit


public final class LedgerBook: NSObject {
    private static var apiKey: String?
    private let productIdentifiers: Set<String> = []
    private var authoritiesCompletion: LedgerBookAuthoritiesCompletion?
    private var productManager: ProductManager!
    
    class func setup(apiKey: String) {
        Self.apiKey = apiKey
    }
    
    public override init() {
        self.productManager = ProductManager()
    }
    
    public func authorities(forceFetch: Bool = false, completion: @escaping LedgerBookAuthoritiesCompletion) {
        
    }
}
