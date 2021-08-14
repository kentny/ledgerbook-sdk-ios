//
//  Cache.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/08.
//

import Foundation
import StoreKit

fileprivate enum UserDefaultsKey: String {
    case products = "products"
    case temporaryAuthorities = "temporaryAuthorities"
}

class Cache: NSObject {
    override init() {
        super.init()
    }
    
    class func save(tempAuthorities: [TemporaryAuthority]) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: tempAuthorities,
                                                           requiringSecureCoding: false) else {
            return
        }
        UserDefaults.standard.set(data, forKey: UserDefaultsKey.temporaryAuthorities.rawValue)
     }
    
    class func loadTempAuthorities() -> [TemporaryAuthority]? {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKey.temporaryAuthorities.rawValue) else {
            return nil
        }
        guard let array = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [TemporaryAuthority] else {
                return nil
        }
        return array
    }
 }
