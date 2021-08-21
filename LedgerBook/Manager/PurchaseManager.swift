//
//  PurchaseManager.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/15.
//

import Foundation
import StoreKit

protocol PurchaseManagerDelegate {
    //課金完了
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete : Bool) -> Void)!)
    //課金完了(中断していたもの)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete : Bool) -> Void)!)
    //リストア完了
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager!)
    //課金失敗
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFailWithErrors errors: [Error])
    //承認待ち(ファミリー共有)
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager!)
}

private let purchaseManagerSharedManager = PurchaseManager()

class PurchaseManager : NSObject,SKPaymentTransactionObserver {

    var delegate : PurchaseManagerDelegate?

    private var productIdentifier: String?
    private var isRestore: Bool = false

    /// Singleton
    class func sharedManager() -> PurchaseManager{
        return purchaseManagerSharedManager;
    }

    /// 課金開始
    func startWithProduct(_ product : SKProduct){
        var errors = [LedgerBookError]()

        if !SKPaymentQueue.canMakePayments() {
            errors.append(.cannotMakePayments)
        }

        if self.productIdentifier != nil {
            errors.append(.productsRequestFailure)
        }

        if self.isRestore {
            errors.append(.restoreInProgress)
        }

        //エラーがあれば終了
        if !errors.isEmpty {
            self.delegate?.purchaseManager(self, didFailWithErrors: errors)
            return
        }

        //未処理のトランザクションがあればそれを利用
        let transactions = SKPaymentQueue.default().transactions
        if transactions.count > 0 {
            for transaction in transactions {
                if transaction.transactionState != .purchased {
                    continue
                }

                if transaction.payment.productIdentifier == product.productIdentifier {
                        self.productIdentifier = product.productIdentifier
                        self.completeTransaction(transaction)
                        return
                }
            }
        }

        //課金処理開始
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        self.productIdentifier = product.productIdentifier
    }

    /// リストア開始
    func startRestore(){
        print("リストア開始")
        if !self.isRestore {
            self.isRestore = true
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            self.delegate?.purchaseManager(self, didFailWithErrors: [LedgerBookError.restoreInProgress])
        }
    }

    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //課金状態が更新されるたびに呼ばれる
        print("paymentQueue, transaction number: \(transactions.count)")
        for transaction in transactions {
            print("transactionIdentifier: \(transaction.transactionIdentifier ?? "nil")")
            switch transaction.transactionState {
            case .purchasing :
                //課金中
                print("paymentQueue: purchasing")
                break
            case .purchased :
                //課金完了
                print("paymentQueue: purchased")
                self.verifyReceipt(completion: { [weak self] result in
                    switch result {
                    case .success(let isSuccess):
                        if isSuccess {
                            self?.completeTransaction(transaction)
                        } else {
                            self?.failedTransaction(transaction)
                        }
                    case .failure(_):
                        self?.failedTransaction(transaction)
                    }
                })
            case .failed :
                //課金失敗
                print("paymentQueue: failed")
                self.failedTransaction(transaction)
            case .restored :
                //リストア
                print("paymentQueue: restored")
                self.verifyReceipt(completion: { [weak self] result in
                    switch result {
                    case .success(let isSuccess):
                        if isSuccess {
                            print("restored - verifyReceipt - success")
                            self?.restoreTransaction(transaction)
                        } else {
                            print("restored - verifyReceipt - not success")
                            self?.failedTransaction(transaction)
                        }
                    case .failure(_):
                        print("restored - verifyReceipt - failed")
                        self?.failedTransaction(transaction)
                    }
                })
            case .deferred :
                //承認待ち
                print("paymentQueue: deferred")
                self.deferredTransaction(transaction)
            @unknown default:
                fatalError()
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        //リストア失敗時に呼ばれる
        print(#function)
        print("Error: \(error)")
        self.delegate?.purchaseManager(self, didFailWithErrors: [error])
        self.isRestore = false
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        //リストア完了時に呼ばれる
        print(#function)
        print("Restore completed.")
        self.delegate?.purchaseManagerDidFinishRestore(self)
        self.isRestore = false
    }



    // MARK: - SKPaymentTransaction process
    private func completeTransaction(_ transaction : SKPaymentTransaction) {
        if transaction.payment.productIdentifier == self.productIdentifier {
            //課金終了
            if let delegate = self.delegate {
                delegate.purchaseManager(self, didFinishPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
                    if complete {
                        //トランザクション終了
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                })
            } else {
                //トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            self.productIdentifier = nil
        } else {
            //課金終了(以前中断された課金処理)
            if let delegate = self.delegate {
                delegate.purchaseManager(self, didFinishUntreatedPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
                    if complete {
                        //トランザクション終了
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                })
            } else {
                //トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }

    private func failedTransaction(_ transaction : SKPaymentTransaction) {
        //課金失敗
        self.delegate?.purchaseManager(self, didFailWithErrors: [transaction.error ?? LedgerBookError.unknown])
        self.productIdentifier = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func restoreTransaction(_ transaction : SKPaymentTransaction) {
        //リストア(originalTransactionをdidFinishPurchaseWithTransactionで通知)　※設計に応じて変更
        self.delegate?.purchaseManager(self, didFinishPurchaseWithTransaction: transaction.original, decisionHandler: { (complete) -> Void in
            if complete {
                //トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        })
    }

    private func deferredTransaction(_ transaction : SKPaymentTransaction) {
        //承認待ち
        self.delegate?.purchaseManagerDidDeferred(self)
        self.productIdentifier = nil
    }
    
    private func verifyReceipt(completion: @escaping ((_ result: Result<Bool>) -> Void)) {
        // TODO
    }
}


