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
    private var authorities = [Authority]()
    private let ledgerBook = LedgerBook()
    private var products: [SKProduct] {
        return self.authorities.reduce([SKProduct]()) { result, authority in
            result + authority.products
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.bounds
        
        self.ledgerBook.delegate = self
        self.ledgerBook.authorities()
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
}

extension ViewController: LedgerBookDelegate {
    func ledgerBook(_ authorities: [Authority], error: LedgerBookError?) {
        DispatchQueue.main.async {
            self.authorities = authorities
            self.tableView.reloadData()
        }
    }
}
