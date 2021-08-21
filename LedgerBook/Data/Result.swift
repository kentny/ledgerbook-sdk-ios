//
//  Result.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/15.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error?)
    
    init(value: T) {
        self = .success(value)
    }
    
    init(error: Error?) {
        self = .failure(error)
    }
}
