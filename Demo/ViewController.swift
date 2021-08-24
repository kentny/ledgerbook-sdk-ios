//
//  ViewController.swift
//  Demo
//
//  Created by Kentaro Terasaki on 2021/08/06.
//

import UIKit
import StoreKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private let tableView = UITableView()
    private var products = [SKProduct]()
    private enum Product: String, CaseIterable {
        case diamond = "com.myapp.diamond"
        case gold = "com.myapp.gold"
        case silver = "com.myapp.silver"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.bounds
        
        let productRequest = SKProductsRequest(productIdentifiers: Set(Product.allCases.map{ $0.rawValue }))
        productRequest.delegate = self
        productRequest.cancel()
        productRequest.start()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = self.products[indexPath.row]
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        let price = formatter.string(from: product.price)!
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(product.localizedTitle)\n\(product.localizedDescription)\n\(String(describing: price))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = self.products[indexPath.row]
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
            self.tableView.reloadData()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("transaction.transactionIdentifier: \(transaction.transactionIdentifier ?? "nil")")
            switch transaction.transactionState {
            case .purchasing:
                print("transactionState: purchasing")
            case .purchased:
                print("transactionState: purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                print("transactionState: deferred")
            case .restored:
                print("transactionState: restored")
            case .failed:
                // Typically, canceled.
                print("transactionState: failed")
                SKPaymentQueue.default().finishTransaction(transaction)
            @unknown default:
                fatalError()
            }
        }
    }
    

}

