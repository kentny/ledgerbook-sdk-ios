//
//  Product.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/29.
//

import Foundation
import StoreKit

public class LedgerBookProduct {
    let name, id: String
    let product: SKProduct

    init(name: String, id: String, product: SKProduct) {
        self.name = name
        self.id = id
        self.product = product
    }
}
