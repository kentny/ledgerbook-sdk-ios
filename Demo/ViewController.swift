//
//  ViewController.swift
//  Demo
//
//  Created by Kentaro Terasaki on 2021/08/06.
//

import UIKit
import StoreKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate {
    private let tableView = UITableView()
    private var products = [SKProduct]()
    private enum Product: String, CaseIterable {
        case diamond = "com.myapp.diamond"
        case gold = "com.myapp.gold"
        case silver = "com.myapp.silver"
        
        func title() -> String {
            switch self {
            case .diamond:
                return "Join DIAMOND Plan"
            case .gold:
                return "Join GOLD Plan"
            case .silver:
                return "Join SILVER Paln"
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return Product.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = Product.allCases[indexPath.row].title()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = Product.allCases[indexPath.row]
        
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
            self.tableView.reloadData()
        }
    }
    
}

