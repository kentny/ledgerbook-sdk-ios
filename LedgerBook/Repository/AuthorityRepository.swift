//
//  AuthorityRepository.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/09.
//

import Foundation

protocol AuthorityRepositoryProtocol: AnyObject {
    func authorities(forceFetch: Bool, completion: @escaping LedgerBookAuthoritiesCompletion)
}

class AuthorityRepository: AuthorityRepositoryProtocol {
    private let productRepository: ProductRepositoryProtocol
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func authorities(forceFetch: Bool = false, completion: @escaping LedgerBookAuthoritiesCompletion) {
        if !forceFetch, let tempAuthorities = Cache.loadTempAuthorities() {
            self.authoritiesFromTemporaryAuthorities(tempAuthorities: tempAuthorities, completion: completion)
        } else {
            self.fetchFromLBServer { [weak self] tempAuthorities, error in
                self?.authoritiesFromTemporaryAuthorities(tempAuthorities: tempAuthorities, completion: completion)
            }
        }
    }

    
    // MARK: - Private methods
    private func fetchFromLBServer(completion: @escaping ([TemporaryAuthority], LedgerBookError?) -> Void) {
        // Fetch authorities from the Ledger Book server.
        let dummyTempAuthorities = [
            TemporaryAuthority(identifier: "auth1", productIds: ["productA", "productB"]),
            TemporaryAuthority(identifier: "auth2", productIds: ["productC", "productD"]),
        ]
        completion(dummyTempAuthorities, nil)
    }
    

    private func authoritiesFromTemporaryAuthorities(tempAuthorities: [TemporaryAuthority], completion: @escaping LedgerBookAuthoritiesCompletion) {
        // Extract product ids from temporary authorities.
        let productIds = tempAuthorities.reduce([String]()) { result, tempAuthority in
            return result + tempAuthority.productIds
        }
        self.productRepository.products(productIdentifiers: productIds) { products, error in
            if error == nil {
                completion([], error)
                return
            }
            
            var authorities: [Authority] = []
            for tempAuthority in tempAuthorities {
                let _products = products.filter({ tempAuthority.productIds.firstIndex(of: $0.productIdentifier) != nil })
                let authority = Authority(identifier: tempAuthority.identifier, products: _products)
                authorities.append(authority)
            }
            completion(authorities, nil)
        }
    }
}
