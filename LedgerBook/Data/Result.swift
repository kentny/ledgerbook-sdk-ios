//
//  Result.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/15.
//

import Foundation

enum Result<T, U: Error> {
    case success(T)
    case failure(U)
    
    init(value: T) {
        self = .success(value)
    }
    
    init(error: U) {
        self = .failure(error)
    }
}
