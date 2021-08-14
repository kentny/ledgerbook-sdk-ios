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
    private let authorityManager: AuthorityManager
    
    class func setup(apiKey: String) {
        Self.apiKey = apiKey
    }
    
    public override init() {
        let productRepository = ProductRepository()
        let authorityRepository = AuthorityRepository(productRepository: productRepository)
        self.authorityManager = AuthorityManager(authorityRepository: authorityRepository)
    }
    
    public func authorities(forceFetch: Bool = false, completion: @escaping LedgerBookAuthoritiesCompletion) {
        self.authorityManager.authorities(forceFetch: forceFetch, completion: completion)
    }
}
