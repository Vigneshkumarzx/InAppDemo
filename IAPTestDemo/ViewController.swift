//
//  ViewController.swift
//  IAPTestDemo
//
//  Created by vignesh kumar c on 02/01/23.
//
import StoreKit
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var models = [SKProduct]()
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    // TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = models[indexPath.row]
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(product.localizedTitle): \(product.localizedDescription) - \(product.priceLocale.currencySymbol ?? "$")\(product.price)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let payment = SKPayment(product: models[indexPath.row])
        SKPaymentQueue.default().add(payment)
    }
    // Products
    enum Products: String, CaseIterable {
        case removeAds = "com.myApp.removeAds"
        case gems = "com.myApp.gems"
        case removeEverything = "com.myApp.removeEverything"
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(Products.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
    }
    // SkPaymentRequst Delegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            print("Count:\(response.products)")
            self.models = response.products
            self.tableView.reloadData()
        }
    }
    // SkpaymentTrasactionObserver delegate
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            switch $0.transactionState {
            case .purchasing:
                print("Purchasing")
            case .purchased:
                print("purchased")
                SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                print("not yet purchased")
            case .restored:
                break
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }
  
}

