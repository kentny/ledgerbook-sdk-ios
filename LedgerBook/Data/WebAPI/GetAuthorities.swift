//
//  GetAuthorities.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/29.
//

import Foundation

class GetAuthoritiesRequest: Request {
    typealias Response = GetAuthoritiesResponse
    
    var httpMethod: HttpMethod {
        return .get
    }
    
    var url: URL {
        let baseURLString = Bundle.main.infoDictionary!["WebAPIBaseURL"] as! String
        let baseURL = URL(string: baseURLString)!
        let requestURL = baseURL.appendingPathComponent("/dev/v1/authority/list")
        return requestURL
    }
    
    var headers: [String : String] {
        let headers: [String: String] = [:]
        return headers
    }
    
    var parameters: [String : Any] {
        let parameters = [:] as [String : Any]
        return parameters
    }
    
    var queryParameters: [URLQueryItem] {
        return [
            URLQueryItem(name: "appId", value: LedgerBook.appId)
        ]
    }

    init() {
    }
}


class GetAuthoritiesResponse: Codable {
    let identifier: String
    let productIds: [String]
    
    init(identifier: String, productIds: [String]) {
        self.identifier = identifier
        self.productIds = productIds
    }
}
