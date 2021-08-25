//
//  Debugger.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/22.
//

import Foundation

var lbDebug: Bool = false
func LBDebugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if lbDebug {
        print("[LBDebug] \(items)", separator: separator, terminator: terminator)
    }
}
