//
//  APIManager.swift
//  devoxxApp
//
//  Created by maxday on 10.12.15.
//  Copyright (c) 2015 maximedavid. All rights reserved.
//

import Foundation
import UIKit
import CoreData

import Crashlytics



let commonUrl:[String : [String]] = ["StoredResource" : ["StoredResource"], "Cfp" : ["Cfp"]]



class APIManager {
    
    
    class func getSelectedEvent() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let selectedEvent = defaults.objectForKey("currentEvent") as? String {
            return selectedEvent
        }
        return ""
    }
    
    class func qrCodeAlreadyScanned() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let _ = defaults.objectForKey("qrCode") as? String {
            return true
        }
        return false
    }
    
    class func clearQrCode() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(nil, forKey: "qrCode")
    }
    
    
    class func setQrCode(str : String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(str, forKey: "qrCode")
    }
    
    class func getQrCode() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.valueForKey("qrCode") as? String

    }
    
    
    
    class func getFallBackData(storedResource : StoredResource) -> NSData? {
        let testBundle = NSBundle.mainBundle()
        let filePath = testBundle.pathForResource(storedResource.fallback, ofType: "")
 
        if filePath != nil {
            return NSData(contentsOfFile: filePath!)!
        }
        return nil
    }
    
    
    
    
    
    class func getDateFromIndex(index : NSInteger, array: NSArray) -> NSDate {

        if index < array.count  {
            if let dict = array.objectAtIndex(index) as? NSDictionary {
                return (dict.objectForKey("date") as? NSDate)!
            }
        }
        //error
        return NSDate()
    }
    
    
    class func getTrackFromIndex(index : NSInteger, array: NSArray) -> String {
        
        if index < array.count  {
            if let dict = array.objectAtIndex(index) as? NSDictionary {
                return (dict.objectForKey("label") as? String)!
            }
        }
        //error
        return ""
    }
    
    

    class func handleData(inputData : NSData, service: AbstractService, storedResource : StoredResource?, etag : String?,completionHandler : (msg: CallbackProtocol) -> Void) {
        
        
   
        
        let json = JSON(data: inputData)
        let arrayToParse = service.getHelper().prepareArray(json)
        var arrayHelper = [DataHelperProtocol]()
        
        print("json: \(json)")
        
        if let appArray = arrayToParse {
            
            
            
            for appDict in appArray {
                let newHelper = service.getHelper()
                newHelper.feed(appDict)
                arrayHelper.append(newHelper)
            }

            service.updateWithHelper(arrayHelper, completionHandler: completionHandler)
        }
        
        storedResource?.etag = etag ?? ""
       
        
    }
    
    
    class func ok(msg:String) {
        //print("OK")
    }
    
    
    class func firstFeed(completionHandler: (msg: CallbackProtocol) -> Void, service : AbstractService) {
        singleCommonFeed(completionHandler, service : service)
    }
    
    
    class func logUserCrash() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
        Crashlytics.sharedInstance().setUserIdentifier("12345")
        Crashlytics.sharedInstance().setUserName("Test User")
    }

    
    class func singleCommonFeed(completionHandler: (msg: CallbackProtocol) -> Void, service : AbstractService) {

        let url = commonUrl[service.getHelper().entityName()]
        
        let testBundle = NSBundle.mainBundle()
        
        for singleUrl in url! {
            
            let filePath = testBundle.pathForResource(singleUrl, ofType: "json")
            let checkString = (try? NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)) as? String
            if(checkString == nil) {
                // print("should not be empty", terminator: "")
            }
            let data = NSData(contentsOfFile: filePath!)!
            
            
            self.handleData(data, service: service, storedResource: nil, etag: nil, completionHandler: completionHandler)

        }
        
        
    }
    
    
    
    
    
    
    
    
    class func dataFromImage(imageName : String) -> NSData? {
        let image = UIImage(named: imageName)
        let nsData = UIImageJPEGRepresentation(image!, 1.0)
        return nsData
    }
    
    
    class func getStringDevice() -> String{
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            return "phone"
        case .Pad:
            return "tablet"
        default :
            return ""
        }
    }
    
    class func getLastFromUrl(url : String) -> String {
        let lastPartImageName = url.characters.split{$0 == "/"}.map(String.init)
        
        //check if well formed URL
        if lastPartImageName.count < 2 {
            return ""
        }
        return lastPartImageName[lastPartImageName.count-1]
    }
    
    
    
    
    
    
    
    
    
    class func isCurrentEventEmpty() -> Bool {
        //return getDistinctDays().count == 0
        return false
        
    }
    
    
}

