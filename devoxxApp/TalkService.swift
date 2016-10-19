//
//  TalkModel.swift
//  My_Devoxx
//
//  Created by Maxime on 12/03/16.
//  Copyright © 2016 maximedavid. All rights reserved.
//

import Foundation
import CoreData


public enum TalksStoreError: Equatable, ErrorType {
    case CannotFetch(String)
}

public func ==(lhs: TalksStoreError, rhs: TalksStoreError) -> Bool {
    switch (lhs, rhs) {
    case (.CannotFetch(let a), .CannotFetch(let b)) where a == b: return true
    default: return false
    }
}


class TalkService : AbstractService {
    
    static let sharedInstance = TalkService()

    override init() {
        super.init()
    }
    
    func fetchTalksByDate(currentDate : NSDate, searchPredicates : [String : [NSPredicate]]?, completionHandler: (_: NSFetchedResultsController?, error: TalksStoreError?) -> Void) {
       
        fetchTalks(currentDate, searchPredicates : searchPredicates, sortByDate : true, completionHandler : completionHandler)
    }
    
    func fetchTalksByTrackId(currentTrack : NSManagedObjectID, completionHandler: (_: NSFetchedResultsController?, error: TalksStoreError?) -> Void) {
        
        let attribute = self.privateManagedObjectContext.objectWithID(currentTrack) as! Attribute
        
        fetchTalks(attribute.label!, searchPredicates : nil, sortByDate : false, completionHandler : completionHandler)
    }
    
    func fetchTalks<T>(criterion : T, searchPredicates : [String : [NSPredicate]]?, sortByDate : Bool, completionHandler: (_: NSFetchedResultsController?, error: TalksStoreError?) -> Void) {
        privateManagedObjectContext.performBlock {
            do {
                let fetchRequest = NSFetchRequest(entityName: "Talk")
                let sortTime = NSSortDescriptor(key: "slot.fromTime", ascending: true)
                let sortAlpha = NSSortDescriptor(key: "slot.roomName", ascending: true)
                let sortFavorite = NSSortDescriptor(key: "isFavorited", ascending: false)
                
               
                
                var sectionNameKeyPath:String
                var predicate:NSPredicate
                
                if sortByDate {
                    sectionNameKeyPath = "slot.fromTime"
                    predicate = NSPredicate(format: "slot.date = %@", criterion as! NSDate)
                    fetchRequest.sortDescriptors = [sortTime, sortFavorite, sortAlpha]
                }
                else {
                    sectionNameKeyPath = "track"
                    predicate = NSPredicate(format: "track = %@", criterion as! String)
                    fetchRequest.sortDescriptors = [sortFavorite, sortAlpha]
                }
                
                fetchRequest.predicate = self.computePredicate(predicate, searchPredicates: searchPredicates)
                
                let frc = NSFetchedResultsController(
                    fetchRequest: fetchRequest,
                    managedObjectContext: self.privateManagedObjectContext,
                    sectionNameKeyPath: sectionNameKeyPath,
                    cacheName: nil)
                
                
                try frc.performFetch()
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(frc, error: nil)
                })
            } catch {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(nil, error: TalksStoreError.CannotFetch("Cannot fetch talks"))
                })
               
            }
        }
    }
    
    
    func setFavoriteStatus(fav:Bool, forTalkWithId talkId:String, completion : (_: CallbackProtocol) -> Void) {
        privateManagedObjectContext.performBlock {
            do {
                
                let fetchRequest = NSFetchRequest(entityName: "Talk")
                let predicate = NSPredicate(format: "id = %@", talkId)
                fetchRequest.predicate = predicate
                
                let items = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest)
                
                if items.count > 0 {
                    let talk = items[0] as! Talk
                    talk.isFavorited = fav
                    super.realSave(completion)
                }
                
            } catch {
                
            }
        }

    }
    
    func fetchTalks(ids : [NSManagedObjectID], completionHandler: (_: [DataHelperProtocol], error: TalksStoreError?) -> Void) {
        privateManagedObjectContext.performBlock {
            
        
            
            var talksArray = [DataHelperProtocol]()
            
            for singleId in ids {
                let obj = self.privateManagedObjectContext.objectWithID(singleId)
                
                if let objCast = obj as? HelperableProtocol {
                    talksArray.append(objCast.toHelper())
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(talksArray, error: nil)
            })
        
        
        }
    }

    
    private func computePredicate(predicate : NSPredicate, searchPredicates : [String : [NSPredicate]]?) -> NSPredicate {

        var andPredicate = [NSPredicate]()
        andPredicate.append(predicate)
        var attributeOrPredicate = [NSPredicate]()
        
        if searchPredicates?.count > 0 {
            for name in searchPredicates!.keys {
                attributeOrPredicate.append(NSCompoundPredicate(andPredicateWithSubpredicates: searchPredicates![name]!))
            }
        }
        
        andPredicate.append(NSCompoundPredicate(andPredicateWithSubpredicates: attributeOrPredicate))
        return NSCompoundPredicate(andPredicateWithSubpredicates: andPredicate)
    }
    
    func getTalkUrl(talkId : String) -> String {
        let cfp = self.privateManagedObjectContext.objectWithID(CfpService.sharedInstance.getCfp()) as! Cfp
        return "\(cfp.cfpEndpoint!)/conferences/\(cfp.id!)/talks/\(talkId)"
    }
    
        


}
