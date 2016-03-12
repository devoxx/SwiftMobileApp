//
//  TalkHelper.swift
//  devoxxApp
//
//  Created by maxday on 10.12.15.
//  Copyright (c) 2015 maximedavid. All rights reserved.
//

import Foundation
import CoreData

class TalkHelper: DataHelperProtocol {
    
    var title: String?
    var lang: String?
    var trackId: String?
    var talkType: String?
    var track: String?
    var id: String?
    var summary: String?
    var isBreak: Bool?
    
    var speakerIds = [String]()
    
    func getMainId() -> String {
        return ""
    }

    
    /*
    override var description: String {
        return "title: \(title)\n lang: \(lang)\n trackId: \(trackId)\n title: \(talkType)\n talkType: \(title)\n id: \(id)\n title: \(title)\n summary: \(summary)\n"
    }
    */
    
    func typeName() -> String {
        return entityName()
    }
    

    
    init(title: String?, lang: String?, trackId: String?, talkType: String?, track: String?, id: String?, summary: String?, isBreak: Bool) {
        self.title = title ?? ""
        self.lang = lang ?? ""
        self.trackId = trackId ?? ""
        self.talkType = talkType ?? ""
        self.track = track ?? ""
        self.id = id ?? ""
        self.summary = summary ?? ""
        self.isBreak = isBreak
    }
    
    func feed(data: JSON) {
      
        title = data["title"].string
        if(title == nil) {
            title = data["nameEN"].string
        }
        lang = data["lang"].string
        trackId = data["trackId"].string
        talkType = data["talkType"].string
        track = data["track"].string
        id = data["id"].string
        summary = data["summary"].string
        
        
        if let speakerArray = data["speakers"].array {
            for spk in speakerArray {
        
                speakerIds.append(spk["link"]["href"].string!)
            }
        }
        
    

    }
    
    func entityName() -> String {
        return "Talk"
    }
    
    func prepareArray(json: JSON) -> [JSON]? {

        if(json["break"] != nil) {
            isBreak = true
            return [json["break"]]
        }
        isBreak = false
        return [json["talk"]]
    }
    
   
    
    func save(managedContext : NSManagedObjectContext)->Bool {
        return false
    }
    
    required init() {
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init()
    }
    
}