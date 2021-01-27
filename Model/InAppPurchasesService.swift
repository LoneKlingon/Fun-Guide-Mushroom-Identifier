//
//  InAppPurchasesService.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-09-08.
//  Copyright © 2018 AYS. All rights reserved.
//

import Foundation
import StoreKit


class InAppPurchasesService: NSObject
{
    
    private override init(){}
    static let shared = InAppPurchasesService()
    var products = [SKProduct]()
    //reference to the payment queue of the appstore
    let paymentQueue = SKPaymentQueue.default()
    
    
    func getProducts()
    {
        let products: Set = [InAppPurchases.consumable.rawValue, InAppPurchases.noncomsumable.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: products)

        request.delegate = self
        request.start()
        paymentQueue.add(self)
        
        
        
    }
    
    func purchase(product: InAppPurchases)
    {
        
        //find product in app store
        guard let productToPurchase = products.filter({$0.productIdentifier == product.rawValue}).first
        else
        {
            return
        }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
        
        
    }
    
    
    func restorePurchases()
    {
        print("Restoring purchases")
        paymentQueue.restoreCompletedTransactions()
    }
    
    func procesessDownload(download: SKDownload) {
        guard let hostedContentPath = download.contentURL?.appendingPathComponent("Contents") else {
            return
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: hostedContentPath.relativePath)
            for file in files {
                let source = hostedContentPath.appendingPathComponent(file)
                //copy to Application Support Path and mark as exclude from iCloud backup
            }
            
            //Delete cached file
            do {
                try FileManager.default.removeItem(at: download.contentURL!)
            } catch {
                //catch error
            }
        } catch {
            //catch error
        }
    }
    
    
    
}

extension InAppPurchasesService: SKProductsRequestDelegate
{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        products = response.products
        
//        print("Printing product titles")
//        for product in response.products
//        {
//
//            print(product.localizedTitle)
//        }
        
    }
    
    
    
}

extension InAppPurchasesService: SKPaymentTransactionObserver
{
    //activates everytime transaction que is changed
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions
        {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
        
            if (transaction.transactionState.status() == "purchased")
            {
                print("Item has been purchased. Saving item to disk...")
                MControl.sharedInstance.savePurchases(product: transaction.payment)
                
                if (transaction.payment.productIdentifier == "com.SOBEAU.FGM.AskExpert")
                {
                    MControl.sharedInstance.addCredit()
                    MControl.sharedInstance.cStatus = true
                }
                
                print("download objects: \(transaction.downloads.count)")
                
                if (transaction.downloads.count > 0)
                {
                    print("triggering download")
                    SKPaymentQueue.default().start(
                        transaction.downloads)
                    
                    print("Download data: \(transaction.downloads)")
                }
                    
                else
                {
                    // Unlock feature or content here before
                    // finishing transaction
                    print("No download objects")
                    SKPaymentQueue.default().finishTransaction(
                        transaction)
                
                }

                
            }
            
            
            
            func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload])
            {
                print("payment Queue download count: \(downloads.count)")
                print("Downloads data: \(downloads)")
                for download in downloads
                {
                    switch download.downloadState
                    {
                        case SKDownloadState.active:
                            print("Download progress \(download.progress)")
                            print("Download time = \(download.timeRemaining)")
                            break
                        case SKDownloadState.finished:
                            // Download is complete. Content file URL is at
                            // path referenced by download.contentURL. Move
                            // it somewhere safe, unpack it and give the user
                            // access to it
                            break
                        default:
                            break
                    }
                }
            }

            
            //clear transaction queue; allows purchasing of multiple consummables
            switch transaction.transactionState
            {
                case .purchasing:
                    break
                default:
                    queue.finishTransaction(transaction)
            }
        
        }
    }
}

extension SKPaymentTransactionState
{
    func status() -> String
    {
        switch self
        {
            case .deferred:
            return "deferred"
            break
            
            case .failed:
            return "failed"
            break
            
            case .purchased:
            return "purchased"
            break
            
            case .purchasing:
            return "purchasing"
            break
            
            case .restored:
            return "restored"
            break
        }
    }
    
}
