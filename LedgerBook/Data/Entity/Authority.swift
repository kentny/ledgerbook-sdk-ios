//
//  Authority.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/06.
//

import Foundation
import StoreKit

//public class Authority {
//    public let identifier: String
//    public let products: [SKProduct]
//
//    public init(identifier: String, products: [SKProduct]) {
//        self.identifier = identifier
//        self.products = products
//    }
//}

public class Authority: Codable {
    let name, id: String

    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
}

class TemporaryAuthority: NSObject, NSCoding {
    let identifier: String
    let productIds: [String]
    
    init(identifier: String, productIds: [String]) {
        self.identifier = identifier
        self.productIds = productIds
     }
    
    required init?(coder: NSCoder) {
        self.identifier = (coder.decodeObject(forKey: "identifier") as? String) ?? ""
        self.productIds = (coder.decodeObject(forKey: "productIds") as? [String]) ?? []
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.identifier, forKey: "identifier")
        coder.encode(self.productIds, forKey: "productIds")
     }
}
