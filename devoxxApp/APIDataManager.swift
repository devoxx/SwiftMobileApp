    //
//  APIDataManager.swift
//  devoxxApp
//
//  Created by got2bex on 2016-03-01.
//  Copyright © 2016 maximedavid. All rights reserved.
//

import Foundation
import UIKit
import CoreData



class APIDataManager {

    

    class func findEntityFromId<T>(id : NSManagedObjectID, inContext context : NSManagedObjectContext) -> T? {
        do {
            if let object = try context.existingObjectWithID(id) as? T {
                return object
            }
        } catch let error1 as NSError {
            print(error1)
        }
        return nil
    }

    
  
    
    
    class func updateCurrentEvent() -> Void {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        
        let fetchRequest = APIManager.buildFetchRequest(context, name: "Cfp")
        let predicateEvent = NSPredicate(format: "id = %@", APIManager.currentEvent!.id!)
        fetchRequest.predicate = predicateEvent
        let items = try! context.executeFetchRequest(fetchRequest)
        
        
        let res = items[0] as! Cfp
       
        APIManager.setEvent(items[0] as! Cfp)
    }

    
    class func getEntryPointPoint() -> String {
        return "\(APIManager.currentEvent.cfpEndpoint!)/conferences/\(APIManager.currentEvent.id!)/schedules"
    }
    
    class func getProposalTypes() -> String {
        return "\(APIManager.currentEvent.cfpEndpoint!)/conferences/\(APIManager.currentEvent.id!)/proposalTypes"
    }
    
    class func getTracks() -> String {
        return "\(APIManager.currentEvent.cfpEndpoint!)/conferences/\(APIManager.currentEvent.id!)/tracks"
    }
    
    class func getSpeakerEntryPoint() -> String {
        return "\(APIManager.currentEvent.cfpEndpoint!)/conferences/\(APIManager.currentEvent.id!)/speakers"
    }
    
    
    
    class func createResource(url : String) -> StoredResource? {
        let httpsUrl = url.stringByReplacingOccurrencesOfString("http:", withString: "https:")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        let helper = StoredResourceHelper(url: httpsUrl, etag: "", fallback: "")
        helper.save(context)
        APIManager.save(context)
        return findResource(httpsUrl)
    }
    
    
    class func findResource(url : String) -> StoredResource? {
        
        
        let httpsUrl = url.stringByReplacingOccurrencesOfString("http:", withString: "https:")
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext!
        let fetchRequest = APIManager.buildFetchRequest(context, name: "StoredResource")
        let predicateEvent = NSPredicate(format: "url = %@", httpsUrl)
        fetchRequest.returnsDistinctResults = true
        fetchRequest.predicate = predicateEvent
        let items = try! context.executeFetchRequest(fetchRequest)
        
        if items.count == 0 {
            return nil
        }
        
        return items[0] as? StoredResource
    }
   
    
   
    
    
    
    class func loadDataFromURL(url: String, dataHelper : DataHelperProtocol, isCritical : Bool, onSuccess : (value:String) -> Void, onError: (value:String)->Void) {
        
        
        var res:StoredResource? = nil
        
        if let storedResource = APIDataManager.findResource(url) {
            res = storedResource
        }
        else {
            if let storedResource = APIDataManager.createResource(url) {
                res = storedResource
            }
            else {
                onError(value: url)
            }
        }
        
        
        if let storedResource = res {
            
        
            return makeRequest(storedResource, dataHelper : dataHelper, isCritical : isCritical, onSuccess: onSuccess, onError: onError)
            
        
        }

        
        else {
            dispatch_async(dispatch_get_main_queue(),{
                onError(value: url)
            })
        }
        
        
    }

    
    class func loadDataFromURLS(urls: NSSet, dataHelper : DataHelperProtocol, isCritical : Bool, onSuccess : (value:String) -> Void, onError: (value:String)->Void) {
        
        for singleUrl in urls {
            if let singleUrlString = singleUrl as? Day {
                loadDataFromURL(singleUrlString.url, dataHelper: dataHelper, isCritical : isCritical, onSuccess: onSuccess, onError: onError)
            }
        }
        
    }

    
    
    
    class func makeRequest(storedResource : StoredResource, dataHelper : DataHelperProtocol, isCritical : Bool, onSuccess : (value:String) -> Void, onError: (value:String)->Void){
        
        
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let headers = [
            "If-None-Match": storedResource.etag
        ]
        
        config.HTTPAdditionalHeaders = headers
        config.requestCachePolicy = .ReloadIgnoringLocalCacheData
        config.timeoutIntervalForResource = 5
        
        let session = NSURLSession(configuration: config)
        
        
        

        
        
        let task = session.dataTaskWithURL(NSURL(string: storedResource.url)!) {
            data, response1, error in
            
            
            
            
            if let responseError = error {
              
                print("No internet for \(storedResource.url)")

                
                if isCritical {
                    
                  
                    
                    let testBundle = NSBundle.mainBundle()
                    let filePath = testBundle.pathForResource(storedResource.fallback, ofType: "")
                    if filePath != nil {
                        let checkString = (try? NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)) as? String
                        if(checkString == nil) {
                            //print("should not be empty", terminator: "")
                        }
                        let fallbackData = NSData(contentsOfFile: filePath!)!
                        
                        dispatch_async(dispatch_get_main_queue(),{
                            
                            APIManager.handleData(fallbackData, dataHelper: dataHelper, storedResource: storedResource, etag: nil)
                            onSuccess(value: storedResource.url)
                        })
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(),{
                            onSuccess(value: storedResource.url)
                        })
                    }
                    
                    
                
                    
                }
                
                else {
                    onSuccess(value: storedResource.url)
                }
                
                
            } else if let httpResponse = response1 as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 && httpResponse.statusCode != 304  {
                    
                    print("Error code for \(storedResource.url)")
                    
                    let statusError = NSError(domain:"devoxx", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    

                    if isCritical {
                        
                        let testBundle = NSBundle.mainBundle()
                        let filePath = testBundle.pathForResource(storedResource.fallback, ofType: "")
                        let checkString = (try? NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)) as? String
                        if(checkString == nil) {
                            //print("should not be empty", terminator: "")
                        }
                        let fallbackData = NSData(contentsOfFile: filePath!)!
                        
                        dispatch_async(dispatch_get_main_queue(),{
                            APIManager.handleData(fallbackData, dataHelper: dataHelper, storedResource: storedResource, etag: nil)
                        })
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        onSuccess(value: storedResource.url)
                    })
                    
                    
                }
                else if httpResponse.statusCode == 304 {
                    
                    print("304 for \(storedResource.url)")
                  
                    
                    if isCritical {
                        
                        let testBundle = NSBundle.mainBundle()
                        let filePath = testBundle.pathForResource(storedResource.fallback, ofType: "")
                        
                        
                        let checkString = (try? NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)) as? String
                        if(checkString == nil) {
                            //print("should not be empty", terminator: "")
                        }
                        let fallbackData = NSData(contentsOfFile: filePath!)!
                        
                        dispatch_async(dispatch_get_main_queue(),{
                            APIManager.handleData(fallbackData, dataHelper: dataHelper, storedResource: storedResource, etag: nil)
                        })
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        onSuccess(value: storedResource.url)
                    })
                    
                }
                else {
                    
                    print("200 for \(storedResource.url)")
                    
                    APIManager.handleData(data!, dataHelper: dataHelper, storedResource : storedResource, etag : httpResponse.allHeaderFields["etag"] as? String)

                    dispatch_async(dispatch_get_main_queue(),{
                        onSuccess(value: storedResource.url)
                    })
                }
            }
        }

   
        task.resume()
    }
    
}