//
//  IAPService.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-09-17.
//  Copyright © 2018 AYS. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class IAPService
{
    static let shared = IAPService()

    
    func completeTransactions()
    {
        
        // see notes below for the meaning of Atomic / Non-Atomic
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        
                        print("Completing transaction")
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }
    
    func getProductInfo(products: Set<String>)
    {
        SwiftyStoreKit.retrieveProductsInfo(products) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
                
            }
                
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
    }
    
    
    
  
    
    //use this function when content is retrieved right away; e.g. no downloaded content
    func purchaseProductAtomic()
    {
        SwiftyStoreKit.purchaseProduct("com.SOBEAU.FGM.AskExpert", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                MControl.sharedInstance.addCredit()
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                }
            }
        }
    }

    //to be used when the content is delivered by the server.

    func purchaseNonAtomic()
    {
        SwiftyStoreKit.purchaseProduct("com.SOBEAU.FGM.FullVersion", quantity: 1, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from your server, then:

                //download content code (Doesn't work blame apple's poor documentation)
//                let downloads = product.transaction.downloads
//                print("Download size: \(downloads.count)")
//                if !downloads.isEmpty {
//                    print("Starting download...")
//                    SwiftyStoreKit.start(downloads)
//                }
//
                MControl.sharedInstance.setMode(version: "full")
                print("Mode: \(MControl.sharedInstance.mode)")
                if product.needsFinishTransaction {
                    print("Ending transaction...")
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
//
                print("Purchase Success: \(product.productId)")
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                }
            }
        }
        
    }
    
    func restorePurchasesAtomic()
    {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    func restorePurchasesNonAtomic()
    {
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                for purchase in results.restoredPurchases {
                    // fetch content from your server, then:

                    if (purchase.productId == "com.SOBEAU.FGM.FullVersion")
                    {
                        MControl.sharedInstance.setMode(version: "full")
                    }
                    
                    
                    //download content code (Doesn't work)
//                    let downloads = purchase.transaction.downloads
//                    print("Download size: \(downloads.count)")
//                    if !downloads.isEmpty {
//                        print("Starting download...")
//                        SwiftyStoreKit.start(downloads)
//                    }
                    
                    
                    if (purchase.productId == "com.SOBEAU.FGM.FullVersion")
                    {
                        //download content from server
                    }

                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    func checkDownloads()
    {
        print("Entering check download")
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
        
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
                    // access to it'
                    print("Finished download")
                    print("Processing download")
                    self.processDownload(download: download)
                    break
                default:
                    break
                }
            }
            
            let contentURLs = downloads.flatMap { $0.contentURL }
            print("Content URL size: \(contentURLs.count)")
            print("Content URL data: \(contentURLs)")
            if contentURLs.count == downloads.count {
                // process all downloaded files, then finish the transaction
                print("Download complete")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
            
            
        }
    }
    
    func processDownload(download: SKDownload)
    {

        let fileManager = FileManager.default

        guard let hostedContentPath = download.contentURL?.appendingPathComponent("Contents") else {
            return
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: hostedContentPath.relativePath)
            for file in files {
                let source = hostedContentPath.appendingPathComponent(file)
                let pathDestination: String = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
                
                let destination = URL(string: pathDestination)
                
                print("Source: \(source); Destination: \(destination)")
                
                //copy to Application Support Path and mark as exclude from iCloud backup
                
                //Remove destination files b/c not allowed to overwrite
                do {
                    try fileManager.removeItem(atPath: pathDestination)
                }catch let err as NSError {
                    print("Could not remove file", err.localizedDescription)
                }
                
                //Move file
                do {
                    try fileManager.moveItem(at: source, to: destination!)
                    print("File \(file) Moved to: \(destination!)")
                }catch let err as NSError {
                    print("Couldn't move file", err.localizedDescription)
                }
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
    
    
//    func processDownloadURL(sender: NSURL)
//    {
//        //Convert URL to String, suitable for NSFileManager
//        var path:String = sender.path!
//        path = path.stringByAppendingPathComponent("Contents")
//
//        //Makes an NSArray with all of the downloaded files
//        let fileManager = FileManager.default
//        var files: NSArray!
//        do {
//            files = try fileManager.contentsOfDirectoryAtPath(path)
//        } catch let err as NSError {
//            print("Error finding zip URL", err.localizedDescription)
//        }
//
//        //For each file, move it to Library
//        for file in files {
//
//            let pathSource: String = path.stringByAppendingPathComponent(file as! String)
//            let pathDestination: String = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
//
//            //Remove destination files b/c not allowed to overwrite
//            do {
//                try fileManager.removeItem(atPath: pathDestination)
//            }catch let err as NSError {
//                print("Could not remove file", err.localizedDescription)
//            }
//
//            //Move file
//            do {
//                try fileManager.moveItem(atPath: pathSource, toPath: pathDestination)
//                print("File", file, "Moved")
//            }catch let err as NSError {
//                print("Couldn't move file", err.localizedDescription)
//            }
//        }
//    }
    
    
}
