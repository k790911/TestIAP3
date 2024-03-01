//
//  ViewController.swift
//  TestIAP3
//
//  Created by 김재훈 on 2/27/24.
//

import UIKit
import StoreKit

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

class ViewController: UIViewController {
    
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    var myToken: Bool?
    var myProductId: Set<String> = ["com.kimjaehoonLabs.TestIAP3.access"]
    var myProducts: SKProduct?
    
    @IBOutlet var bought: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myToken = UserDefaults.standard.bool(forKey: "bought")
        
        if myToken == false {
            bought.text = "X"
        } else {
            bought.text = "O"
        }
    }

    @IBAction func buyProduct(_ sender: UIButton) {
        print("button touched.")
        SKPaymentQueue.default().add(self)
        
        requestProduct { success, products in
            if success {
                self.buyProduct(self.myProducts!)
            } else {
                print("there are no products online.")
            }
        }  
    }
    
    // App Stroe Connect에서 등록한 인앱결제 상품을 가져올떄
    public func requestProduct(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()

        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: myProductId)
        productsRequest!.delegate = self
        productsRequest?.start()
    }
    
    // 인앱결제 상품을 구입할 때
    public func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // 구입 내역을 복원할 때
    public func restorePurchase() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

}

extension ViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        myProducts = response.products[0]
        productsRequestCompletionHandler?(true, nil)
        
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
    
    
}

extension ViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchased:
                DispatchQueue.main.async {
                    self.bought.text = "O"
                }
                
                UserDefaults.standard.set(true, forKey: "bought")
                
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                print("purchase failed.")
                SKPaymentQueue.default().finishTransaction(transaction)
            
            case .restored:
                print("purchase restored.")
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred, .purchasing:
                print("purchase deferred or purchasing.")
                break
                
            @unknown default:
                print("purchase @unknown default.")
                fatalError()
            }
        }
    }
}
