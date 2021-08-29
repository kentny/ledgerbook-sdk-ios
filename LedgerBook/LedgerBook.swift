//
//  LedgerBook.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/08.
//

import Foundation
import StoreKit

public protocol LedgerBookDelegate: AnyObject {
    func ledgerBook(_ authorities: [Authority], error: LedgerBookError?)
}

public final class LedgerBook: NSObject {
    static var appId: String?
    private let authorityManager: AuthorityManager
    
    public var delegate: LedgerBookDelegate?
    
    public class func setup(appId: String, debug: Bool = false) {
        lbDebug = debug
        LBDebugPrint("setup, appId: \(appId)")
        Self.appId = appId
    }
    
    public override init() {
        let productRepository = ProductRepository()
        let authorityRepository = AuthorityRepository(productRepository: productRepository)
        self.authorityManager = AuthorityManager(authorityRepository: authorityRepository)
    }
    
    public func authorities(forceFetch: Bool = false) {
        self.authorityManager.authorities(forceFetch: forceFetch) { [weak self] authorities, error in
            self?.delegate?.ledgerBook(authorities, error: error)
        }
    }
}
