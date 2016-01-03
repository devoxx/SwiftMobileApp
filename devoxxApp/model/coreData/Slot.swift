//
//  Slot.swift
//  devoxxApp
//
//  Created by maxday on 10.12.15.
//  Copyright (c) 2015 maximedavid. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Slot: NSManagedObject, CellDataPrococol, FeedableProtocol, FavoriteProtocol, SearchableProcotol {

    @NSManaged var roomName: String
    @NSManaged var slotId: String
    @NSManaged var fromTime: String
    @NSManaged var day: String
    
    @NSManaged var toTimeMillis: NSNumber
    
    @NSManaged var talk: Talk

    func getPrimaryImage() -> UIImage? {
        return UIImage(named: talk.getIconFromTrackId())
    }
    
    func getFirstInformation() -> String {
        return talk.title
    }
    
    func getSecondInformation() -> String {
        return roomName
    }
    
    func getThirdInformation() -> String {
        return talk.getShortTalkTypeName()
    }
    
    func getColor() -> UIColor? {
        return ColorManager.getColorFromTalkType(talk.talkType)
    }
    
    func feedHelper(helper: DataHelperProtocol) -> Void {
        if let castHelper = helper as? SlotHelper  {
            roomName = castHelper.roomName!
            slotId = castHelper.slotId!
            fromTime = castHelper.fromTime!
            day = castHelper.day!
        }
    }
    
    func getElement() -> NSManagedObject {
        return talk
    }

    func getIdentifier() -> String {
        return talk.title
    }
    
    func invertFavorite() -> Bool {
        return APIManager.invertFavorite("Talk", identifier: getIdentifier())
    }
    
    func favorited() -> Bool {
        return APIManager.isFavorited("Talk", identifier: getIdentifier())
    }
    
    func isMatching(str : String) -> Bool {
        return getFirstInformation().lowercaseString.containsString(str.lowercaseString)
    }
    
}
