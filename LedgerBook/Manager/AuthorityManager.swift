//
//  AuthorityManager.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/08.
//

import Foundation

public typealias LedgerBookAuthoritiesCompletion = ([Authority], LedgerBookError?) -> Void

class AuthorityManager: NSObject {
    private let authorityRepository: AuthorityRepositoryProtocol
    
    init(authorityRepository: AuthorityRepository) {
        self.authorityRepository = authorityRepository
    }
    
    func authorities(forceFetch: Bool = false, completion: @escaping LedgerBookAuthoritiesCompletion) {
        self.authorityRepository.authorities(forceFetch: forceFetch, completion: completion)
    }
}
