//
//  ProductManagerTests.swift
//  LedgerBookTests
//
//  Created by Kentaro Terasaki on 2021/09/18.
//

import XCTest
import StoreKit
@testable import LedgerBook

class ProductManagerTests: XCTestCase {
    var productManager: ProductManager!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.productManager = ProductManager(ProductRepositoryMock())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testProducts() throws {
        let expectation = self.expectation(description: "Get product list.")
        self.productManager.products(productIdentifiers: ["xxx", "yyy"]) { products, error in
            XCTAssertTrue(products.isEmpty)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
}

class ProductRepositoryMock: NSObject, ProductRepositoryProtocol {
    func products(productIdentifiers: [String], completion: @escaping LedgerBookProductsCompletion) {
        completion([], nil)
    }

    func fetchProductsFromLedgerBookServer() {
        
    }
}
