//
//  AppDelegate.swift
//  devoxxApp
//
//  Created by maxday on 09.12.15.
//  Copyright (c) 2015 maximedavid. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

//Fabric/CrashAnalytics
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var session: WCSession?
    
    func resourceReady(msg: CallbackProtocol) -> Void {
        //TODO
       
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        initWatchConnectivity()
        
        Fabric.with([Crashlytics.self])

        //Crashlytics.sharedInstance().debugMode = true
        
        //dunno why, first time UITextView is called, the UI freezes for about 1 sec, so by doing it here, the user wont be affected (workaround)
        let _ = UITextView()
        
        APIManager.firstFeed(resourceReady, service: StoredResourceService.sharedInstance)
        
        let color = ColorManager.topNavigationBarColor
        UINavigationBar.appearance().barTintColor = color
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        UIPageControl.appearance().pageIndicatorTintColor = ColorManager.topNavigationBarColor
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.lightGrayColor()
        
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        //self.window!.rootViewController = tabController
        
        let nav = ViewController()
        
        self.window!.rootViewController = nav
        self.window!.makeKeyAndVisible()
        
       
    
        return true
    }
    
    func t() {}
    
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.coreDataHelper.saveContext()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.coreDataHelper.saveContext()
    }
    
    lazy var mainManager: MainManager = {
        let mainManager = MainManager()
        return mainManager
    }()
    
    lazy var coreDataHelper: CoreDataHelper = {
        let coreDataHelper = CoreDataHelper()
        return coreDataHelper
    }()
}

extension AppDelegate: WCSessionDelegate {
    func initWatchConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
        }
    }
    
    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        print("to do")
    }
    
    func sessionDidBecomeInactive(session: WCSession) {
        print("to do")
    }
    
    func sessionDidDeactivate(session: WCSession) {
        print("to do")
    }

    
    func updateFavoriteStatus(favorite:Bool, forTalkWithId talkId:String, inConferenceWithId conferenceId:String) {
        if let session = session {
            let message = ["favorite":["value":favorite, "talkId":talkId, "conferenceId":conferenceId]]
            if session.reachable {
                session.sendMessage(message, replyHandler: { (reply:[String : AnyObject]) in
                    
                    }, errorHandler: { (error:NSError) in
                        print(error)
                })
            } else {
                session.transferUserInfo(message)
            }
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        processMessage(message)
    }
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        processMessage(userInfo)
    }
    
    private func processMessage(message:[String: AnyObject]) {
        if let favorite = message["favorite"] as? [String:AnyObject] {
            if let id = favorite["talkId"] as? String, fav = (favorite["favorite"] as? NSNumber)?.boolValue {
                unscheduleLocalNotificationForTalkWithId(id)
                self.setFavoriteStatus(fav, forTalkWithId:id)
                if fav {
                    let title = favorite["title"] as? String
                    let room = favorite["room"] as? String
                    let fromTimeMillis = favorite["fromTimeMillis"] as? NSNumber
                    let fromTime = favorite["fromTime"] as? String
                    let toTime = favorite["toTime"] as? String
                    
                    scheduleLocalNotificationForTalkWithId(id, title: title!, room: room!, fromTime: fromTime!, toTime: toTime!, fromTimeMillis: fromTimeMillis!)
                }
            }
        }
    }
    
    private func setFavoriteStatus(fav:Bool, forTalkWithId talkId:String) {
        TalkService.sharedInstance.setFavoriteStatus(fav, forTalkWithId: talkId, completion : sendNotif)
    }
    
    
    
    private func sendNotif(msg : CallbackProtocol) {
        if msg.getMessage() == "OK" {
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateFavorite", object: nil)
        }
    }
    
    func scheduleLocalNotificationForTalkWithId(id:String, title:String, room:String, fromTime:String, toTime:String, fromTimeMillis:NSNumber){
        let date = NSDate(timeIntervalSince1970: fromTimeMillis.doubleValue / 1000)
        let notification = UILocalNotification()
        notification.fireDate = date.dateByAddingTimeInterval(-10*60)
        notification.timeZone = NSTimeZone.localTimeZone()
        notification.userInfo = [
            "id": id,
            "title":title,
            "room":room,
            "fromTimeMillis":fromTimeMillis,
            "fromTime":fromTime,
            "toTime":toTime
        ]
        notification.alertTitle = title
        notification.alertBody = String(format: NSLocalizedString("From %@ to %@ in %@", comment: ""), arguments: [fromTime, toTime, room])
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func unscheduleLocalNotificationForTalkWithId(id:String) {
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if let userInfo = notification.userInfo {
                if let talkId = userInfo["id"] as? String {
                    if talkId == id {
                        UIApplication.sharedApplication().cancelLocalNotification(notification)
                    }
                }
            }
        }
    }
}

