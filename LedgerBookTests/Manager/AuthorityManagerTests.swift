//
//  AuthorityManagerTests.swift
//  LedgerBookTests
//
//  Created by Kentaro Terasaki on 2021/08/14.
//

import XCTest
import StoreKit
@testable import LedgerBook

class AuthorityManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAuthorities() throws {
        let dummyAuthorities1 = [
            Authority(identifier: "auth1", products: [SKProduct(), SKProduct()]),
            Authority(identifier: "auth2", products: [SKProduct(), SKProduct(), SKProduct()]),
        ]
        let dummyAuthorities2 = [
            Authority(identifier: "auth3", products: [SKProduct(), SKProduct()]),
            Authority(identifier: "auth4", products: [SKProduct()]),
            Authority(identifier: "auth5", products: [SKProduct(), SKProduct(), SKProduct()]),
        ]
        
        let mock = MockAuthorityRepository(authorities1: dummyAuthorities1, authorities2: dummyAuthorities2)
        let authorityManager = AuthorityManager(authorityRepository: mock)
        let expectation1 = self.expectation(description: "Get authorities with forced fetch.")
        authorityManager.authorities(forceFetch: true) { authorities, error in
            XCTAssertNil(error)
            XCTAssertTrue(authorities.count == dummyAuthorities1.count)
            XCTAssertTrue(authorities[0].identifier == dummyAuthorities1[0].identifier)
            expectation1.fulfill()
        }
        
        let expectation2 = self.expectation(description: "Get authorities without forced fetch.")
        authorityManager.authorities(forceFetch: false) { authorities, error in
            XCTAssertNil(error)
            XCTAssertTrue(authorities.count == dummyAuthorities2.count)
            XCTAssertTrue(authorities[0].identifier == dummyAuthorities2[0].identifier)
            expectation2.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
}

class MockAuthorityRepository: AuthorityRepositoryProtocol {
    private let authorities1: [Authority]
    private let authorities2: [Authority]
    
    init(authorities1: [Authority], authorities2: [Authority]) {
        self.authorities1 = authorities1
        self.authorities2 = authorities2
    }
    
    func authorities(forceFetch: Bool, completion: @escaping LedgerBookAuthoritiesCompletion) {
        
        if forceFetch {
            completion(self.authorities1, nil)
        } else {
            completion(self.authorities2, nil)
        }
    }
}
