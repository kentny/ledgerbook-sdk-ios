//
//  Request.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/25.
//

import Foundation

protocol Request {
    
    associatedtype Response
    
    var httpMethod: HttpMethod { get }
    var url: URL { get }
    var headers: [String : String] { get }
    var parameters: [String : Any] { get }
    var queryParameters: [URLQueryItem] { get }
    
    func responseFromJsonObject(_ jsonObject: [String : Any]) -> Response?
}

extension Request {
    var endpontURL: URL {
        // This plist file is only for LedgerBook service developers and not published in GtiHub.
        let path = Bundle(identifier: "com.kentaro.LedgerBook")!.path(forResource: "LedgerBook", ofType: "plist")
        let configurations = NSDictionary(contentsOfFile: path!)!
        let urlString = configurations["WebAPIEndpoint"] as! String
        return URL(string: urlString)!
    }
    
    var headers: [String : String] {
        return [:]
    }
    
    var parameters: [String : Any] {
        return [:]
    }
}

extension Request where Response: Codable {
    
    func responseFromJsonObject(_ jsonObject: [String : Any]) -> Response? {
        // TODO: Decode data into JSON by codable.
        return nil
//        guard let model = Mapper<Response>().map(JSON: jsonObject) else {
//            return nil
//        }
//        return model
    }
}
