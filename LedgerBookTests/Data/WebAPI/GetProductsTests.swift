//
//  GetProductsTests.swift
//  LedgerBookTests
//
//  Created by Kentaro Terasaki on 2021/08/29.
//

import XCTest
@testable import LedgerBook

class GetProductsTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // This plist file is only for LedgerBook service developers and not published in GtiHub.
        let path = Bundle(identifier: "com.kentaro.LedgerBook")!.path(forResource: "LedgerBook", ofType: "plist")
        let configurations = NSDictionary(contentsOfFile: path!)!
        let appId = configurations["AppId"] as! String
        LedgerBook.setup(appId: appId, debug: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetProducts() throws {
        let expectation = self.expectation(description: "Get products via Web API.")
        let request = GetProductsRequest()
        
        APIClient.sendRequest(request: request, success: { response in
            XCTAssertNotNil(response)
            XCTAssertTrue(response!.count > 0)
            expectation.fulfill()
        }, failure: { error in
            switch error! {
            case let .apiError(detail: apiError):
                XCTAssertTrue(false, "API Error(\(apiError.code) - \(apiError.message)")
            default:
                XCTAssertTrue(false, "Some Error happend(\(error!.localizedDescription)")
            }
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
