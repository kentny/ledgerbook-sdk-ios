//
//  LedgerBook.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/08.
//

import Foundation
import StoreKit

//public protocol LedgerBookDelegate: AnyObject {
//    func ledgerBook(_ products: [SKProduct], error: LedgerBookError?)
//    func ledgerBook(_ authorities: [Authority], error: LedgerBookError?)
//    func ledgerBookDidFinishPurchase(_ product: SKProduct, error: LedgerBookError?)
//}

public enum LedgerBookMode {
    case remote
    case local
}

public final class LedgerBook: NSObject {
    // MARK: Singleton
    private static let sharedInstance = LedgerBook()

    static var appId: String? { return sharedInstance._appId }
    static var secret: String? { return sharedInstance._secret }
    static var mode: LedgerBookMode? { return sharedInstance._mode }
    static var useSandbox: Bool { return sharedInstance._useSandbox }
    
    // MARK: Private variables/constants
    private var _appId: String?
    private var _secret: String?
    private var _mode: LedgerBookMode?
    private var _useSandbox = false
    //    private let authorityManager: AuthorityManager
    private var skProducts = [SKProduct]()
    private let productManager: ProductManager
//    public var delegate: LedgerBookDelegate?
    

    override init() {
        let productRepository = ProductRepository()
        self.productManager = ProductManager(productRepository)
//        let authorityRepository = AuthorityRepository(productRepository: productRepository)
//        self.authorityManager = AuthorityManager(authorityRepository)
    }

    public class func setup(appId: String, debug: Bool = false) {
        lbDebug = debug
        LBDebugPrint("setup, appId: \(appId)")
        Self.sharedInstance._appId = appId
        Self.sharedInstance._secret = nil
    }

    public class func setup(secret: String, useSandbox: Bool = false, debug: Bool = false) {
        lbDebug = debug
        LBDebugPrint("setup, secret: \(secret)")
        Self.sharedInstance._appId = nil
        Self.sharedInstance._secret = secret
        Self.sharedInstance._mode = .local
        Self.sharedInstance._useSandbox = useSandbox
    }

    public class func observeTransaction(observer: @escaping (SKPaymentTransaction) -> Void) {
        PurchaseManager.addObserve(observer: observer)
    }
    
    public class func retrieveProducts(identifiers: [String], completion: @escaping ([SKProduct], LedgerBookError?) -> Void) {
        switch Self.mode {
        case .local:
            break
        default:
            fatalError("LedgerBook mode must be `local` to call this method.")
        }
        Self.sharedInstance.productManager.products(productIdentifiers: identifiers) { skProducts, error in
            Self.sharedInstance.skProducts = skProducts
            completion(skProducts, error)
        }
    }
    
    public class func purchase(productId: String, completion: @escaping (SKPaymentTransaction?, LedgerBookError?) -> Void) {
        LBDebugPrint("purchase `\(productId)`")
        if let purchaseProduct = Self.sharedInstance.skProducts.first(where: { $0.productIdentifier == productId }) {
            self.purchase(product: purchaseProduct, completion: completion)
        } else {
            LBDebugPrint("Target product Id is not retrieved yet. Retrieve it at first.")
            Self.retrieveProducts(identifiers: [productId]) { skProducts, error in
                if error != nil, !skProducts.isEmpty {
                    Self.purchase(product: skProducts[0], completion: completion)
                } else {
                    completion(nil, .productsRequestFailure)
                }
            }
        }
    }

    public class func purchase(product: SKProduct, completion: @escaping (SKPaymentTransaction?, LedgerBookError?) -> Void) {
        PurchaseManager.purchase(product) { result in
            switch result {
            case .success(let transaction):
                completion(transaction, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    public class func restore(completion: @escaping (SKPaymentTransaction?, LedgerBookError?) -> Void) {
        PurchaseManager.restore { result in
            switch result {
            case .success(let transaction):
                completion(transaction, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    public class func completeTransaction(_ transaction: SKPaymentTransaction) {
        PurchaseManager.completeTransaction(transaction)
    }

//    public func products(forceFetch: Bool = false) {
//        switch Self.mode {
//        case .remote:
//            break
//        default:
//            fatalError("LedgerBook mode must be `remote` to call this method.")
//        }
//    }
    
//    public func authorities(forceFetch: Bool = false) {
//        self.authorityManager.authorities(forceFetch: forceFetch) { [weak self] authorities, error in
//            self?.delegate?.ledgerBook(authorities, error: error)
//        }
//    }
}
