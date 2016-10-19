//
//  ExtensionDelegate.swift
//  Smartvoxx Extension
//
//  Created by Sebastien Arbogast on 09/04/2016.
//  Copyright © 2016 maximedavid. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    private var session:WCSession?

    func applicationDidFinishLaunching() {
        initWatchConnectivity()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}

extension ExtensionDelegate:WCSessionDelegate {
    func initWatchConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
        }
    }
    
    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        print("OK")
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        processMessage(message)
    }
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        processMessage(userInfo)
    }
    
    private func processMessage(message:[String:AnyObject]) {
        if let favorite = message["favorite"] as? [String:AnyObject] {
            if let value = favorite["value"] as? Bool, talkId = favorite["talkId"] as? String, conferenceId = favorite["conferenceId"] as? String {
                DataController.sharedInstance.setFavorite(value, forTalkWithId:talkId, inConferenceWithId:conferenceId) { (talkSlot:TalkSlot) in
                    NSNotificationCenter.defaultCenter().postNotificationName("talkFavoriteStatusChanged", object: nil, userInfo: ["talkSlot":talkSlot])
                }
            }
        }
    }
    
    func updateFavoriteStatusForTalkSlot(talkSlot:TalkSlot) {
         let talkSlotMessage = [
            "title":talkSlot.title!,
            "room":talkSlot.roomName!,
            "talkId":talkSlot.talkId!,
            "conferenceId":talkSlot.schedule!.conference!.conferenceId!,
            "track":talkSlot.track!.name!,
            "favorite":talkSlot.favorite!,
            "fromTimeMillis":talkSlot.fromTimeMillis!,
            "fromTime":talkSlot.fromTime!,
            "toTime":talkSlot.toTime!
         ]
         
         if let session = self.session where session.reachable {
            session.sendMessage(["favorite" : talkSlotMessage], replyHandler: { (reply:[String : AnyObject]) -> Void in
         
                }, errorHandler: { (error:NSError) -> Void in
                    print(error)
            })
         } else {
            session?.transferUserInfo(["favorite" : talkSlotMessage as NSDictionary])
         }
    }
}
