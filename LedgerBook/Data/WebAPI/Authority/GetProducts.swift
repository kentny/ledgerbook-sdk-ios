//
//  GetProducts.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/29.
//

import Foundation

class GetProducts: Request {
    typealias Response = GetProductsResponse
    
    var httpMethod: HttpMethod {
        return .get
    }
    
    var url: URL {
        let baseURLString = Bundle.main.infoDictionary!["WebAPIBaseURL"] as! String
        let baseURL = URL(string: baseURLString)!
        let requestURL = baseURL.appendingPathComponent("/dev/v1/product/list")
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


class GetProductsResponse: Codable {
    let id: String
    let appId: String
    let name: String
    let store: String
    let authority: Authority
    let createdAt, updatedAt: Date

    init(appId: String, id: String, store: String, name: String, authority: Authority, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.appId = appId
        self.store = store
        self.name = name
        self.authority = authority
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


//// MARK: - WelcomeElement
//class WelcomeElement: Codable {
//    let appID, id, store, name: String
//    let authority: Authority
//    let createdAt, updatedAt: Date
//
//    enum CodingKeys: String, CodingKey {
//        case appID = "appId"
//        case id, store, name, authority, createdAt, updatedAt
//    }
//
//    init(appID: String, id: String, store: String, name: String, authority: Authority, createdAt: Date, updatedAt: Date) {
//        self.appID = appID
//        self.id = id
//        self.store = store
//        self.name = name
//        self.authority = authority
//        self.createdAt = createdAt
//        self.updatedAt = updatedAt
//    }
//}
//
