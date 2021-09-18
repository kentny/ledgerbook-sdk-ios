//
//  PurchaseManager.swift
//  LedgerBook
//
//  Created by Kentaro Terasaki on 2021/08/15.
//

import Foundation
import StoreKit

class PurchaseManager: NSObject, SKPaymentTransactionObserver {

    // MARK: Singleton
    private static let sharedInstance = PurchaseManager()
    
    private var transactionObservers = [(SKPaymentTransaction) -> Void]()
    private var purchaseCompletion: ((Result<SKPaymentTransaction, LedgerBookError>) -> Void)?
    private var restoreCompletion: ((Result<SKPaymentTransaction, LedgerBookError>) -> Void)?
    private var processingProductIdentifier: String?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    /// Observe transactions.
    class func addObserve(observer: @escaping (SKPaymentTransaction) -> Void) {
        sharedInstance.transactionObservers.append(observer)
    }
    
    /// Remove all observers.
    class func removeAllObserver() {
        sharedInstance.transactionObservers.removeAll()
    }
    
    /// Start purchasing product.
    class func purchase(_ product : SKProduct, completion: @escaping (Result<SKPaymentTransaction, LedgerBookError>) -> Void) {
        if !SKPaymentQueue.canMakePayments() {
            completion(Result(error: .cannotMakePayments))
            return
        }

        if sharedInstance.processingProductIdentifier != nil {
            completion(Result(error: .purchaseInProgress))
            return
        }

        // Use unprocessed transaction(s) if any...
        let transactions = SKPaymentQueue.default().transactions
        if transactions.count > 0 {
            for transaction in transactions {
                if transaction.transactionState != .purchased {
                    continue
                }

                if transaction.payment.productIdentifier == product.productIdentifier {
                    sharedInstance.processingProductIdentifier = product.productIdentifier
                    completion(Result(value: transaction))
                    return
                }
            }
        }

        sharedInstance.purchaseCompletion = completion

        // Start payment process.
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        sharedInstance.processingProductIdentifier = product.productIdentifier
    }

    /// Start restore.
    class func restore(completion: @escaping (Result<SKPaymentTransaction, LedgerBookError>) -> Void){
        LBDebugPrint("Start Restoring.")
        sharedInstance.restoreCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    /// Complete purchase processes.
    class func completeTransaction(_ transaction : SKPaymentTransaction) {
        sharedInstance.processingProductIdentifier = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //課金状態が更新されるたびに呼ばれる
        LBDebugPrint("paymentQueue, transaction number: \(transactions.count)")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.purchaseCompletion?(Result(value: transaction))
            case .restored:
                self.restoreCompletion?(Result(value: transaction))
            case .purchasing:
                break
            case .failed, .deferred:
                Self.completeTransaction(transaction)
            @unknown default:
                break
            }

            for observer in self.transactionObservers {
                observer(transaction)
            }
        }
    }

    /// Finished restoring
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        LBDebugPrint("Restore completed.")
    }
    
    /// Failed to restore
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        LBDebugPrint("Restore failed error: \(error)")
        self.restoreCompletion?(Result(error: .transactionFailure(SKError(_nsError: error as NSError))))
    }

    class func verifyReceipt(completion: @escaping ((_ result: Result<Bool, LedgerBookError>) -> Void)) {
        // verify receipt URL
        var urlString = ""
        if LedgerBook.useSandbox {
            urlString = Bundle(for: Self.self).object(forInfoDictionaryKey: "Verify Receipt URL (sandbox)") as! String
        } else {
            urlString = Bundle(for: Self.self).object(forInfoDictionaryKey: "Verify Receipt URL") as! String
        }
        let url = URL(string: urlString)!
        
//
//        let apiToken = Bundle.main.object(forInfoDictionaryKey: "Firebase API Token") as! String
//        let url = URL(string: urlString)!
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
//        components?.queryItems = [
//            URLQueryItem(name: "token", value: apiToken)
//        ]
//        let queryStringAddedUrl = components?.url
//
//        // Get receipt if available
//        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
//        FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
//
//            do {
//                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
//                print(receiptData)
//
//                let receiptBase64String = receiptData.base64EncodedString(options: [])
//                print("receiptBase64String: \(receiptBase64String)")
//
//                guard let userId = SettingRepository.loadUserId() else {
//                    throw NSError(domain: "User IDが空っぽ", code: -1, userInfo: nil)
//                }
//
//                let json: [String: Any] = [
//                    "receipt_string": receiptBase64String,
//                    "user_id": userId,
//                ]
//                let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//
//                var request = URLRequest(url: queryStringAddedUrl!)
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.httpMethod = "POST"
//                request.httpBody = jsonData
//
//                let session = URLSession.shared
//                session.dataTask(with: request) { (data, response, error) in
//                    if error == nil, let response = response as? HTTPURLResponse {
//                        // HTTPヘッダの取得
//                        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
//                        // HTTPステータスコード
//                        print("statusCode: \(response.statusCode)")
//
////                        if let data = data {
////                            print(String(data: data, encoding: .utf8) ?? "")
////                        } else {
////                            print("response data is nil.")
////                        }
//
//                        if response.statusCode == 200, let data = data {
//                            print(String(data: data, encoding: .utf8) ?? "")
//                            do {
//                                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any]
//                                let isPremiumUser = json?["is_premium_user"] as? Bool ?? false
//                                completion(Result<Bool>(value: isPremiumUser))
//                            } catch {
//                                print("Serialize Error")
//                                completion(Result<Bool>(error: error))
//                            }
//                        } else {
//                            completion(Result<Bool>(error: error))
//                        }
//                    }
//                }.resume()
//            } catch {
//                print("Couldn't read receipt data with error: " + error.localizedDescription)
//                let result = Result<Bool>(error: error)
//                completion(result)
//            }
//        } else {
//            print("Receipt data is empty...")
//            completion(Result<Bool>(value: false))
//        }
//        // get receipt data
        
    }
}


