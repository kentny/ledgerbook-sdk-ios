//
//  ViewController.swift
//  Demo
//
//  Created by Kentaro Terasaki on 2021/08/06.
//

import UIKit
import StoreKit
import LedgerBook

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView()
    private var products = [SKProduct]()
    private enum Product: String, CaseIterable {
        case diamond = "com.myapp.diamond"
        case gold = "com.myapp.gold"
        case silver = "com.myapp.silver"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.bounds
        
        
        LedgerBook.retrieveProducts(identifiers: Product.allCases.map({$0.rawValue})) { products, error in
            DispatchQueue.main.async {
                self.products = products
                self.tableView.reloadData()
            }
        }
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
        
        LedgerBook.purchase(product: product) { transaction, error in
            if error != nil || transaction == nil {
                print("Error occurred.")
                return
            }
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Purchased", message: "Complete purchasing (\(transaction!.payment.productIdentifier))", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
                LedgerBook.completeTransaction(transaction!)
            }
        }
    }
}

//extension ViewController: LedgerBookDelegate {
//    func ledgerBook(_ products: [SKProduct], error: LedgerBookError?) {
//        DispatchQueue.main.async {
//            self.products = products
//            self.tableView.reloadData()
//        }
//    }
//
//    func ledgerBook(_ authorities: [Authority], error: LedgerBookError?) {
//        DispatchQueue.main.async {
//            self.authorities = authorities
//            self.tableView.reloadData()
//        }
//    }
//}
