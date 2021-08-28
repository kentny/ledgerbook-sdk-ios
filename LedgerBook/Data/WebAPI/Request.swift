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
    var baseURL: URL { get }
    var path: String { get }
    var headers: [String : String] { get }
    var parameters: [String : Any] { get }
    
    func responseFromJsonObject(_ jsonObject: [String : Any]) -> Response?
}

extension Request {
    
    var headers: [String : String] {
        return [:]
    }
    
    var parameters: [String : Any] {
        return [:]
    }
}

extension Request where Response: Codable {
    
    func responseFromJsonObject(_ jsonObject: [String : Any]) -> Response? {
        // TODO
        return nil
//        guard let model = Mapper<Response>().map(JSON: jsonObject) else {
//            return nil
//        }
//        return model
    }
}