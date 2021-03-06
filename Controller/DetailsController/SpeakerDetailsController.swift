//
//  SpeakerDetailsController.swift
//  devoxxApp
//
//  Created by got2bex on 2016-02-27.
//  Copyright © 2016 maximedavid. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class SpeakerDetailsController : AbstractDetailsController, UITableViewDelegate, UITableViewDataSource, HotReloadProtocol, FavoritableProtocol {
    

    var talkList = SpeakerListView(frame: CGRectZero, style: .Grouped)
    
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        view.addSubview(talkList)
        
        //talkList.backgroundColor = UIColor.redColor()
        talkList.delegate = self
        talkList.dataSource = self
        
        
        
        
        
        let views = ["header": header, "scroll" : scroll, "talkList" : talkList]
        
        
        let constH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[header]-0-|", options: .AlignAllCenterX, metrics: nil, views: views)
        let constH2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[scroll]-10-|", options: .AlignAllCenterX, metrics: nil, views: views)
        
        let constH3 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[talkList]-10-|", options: .AlignAllCenterX, metrics: nil, views: views)
        
        
        
        
        let constV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[header(150)]-[scroll]-[talkList(200)]-0-|", options: .AlignAllCenterX, metrics: nil, views: views)
        
        
        
        
        
        
        
        view.addConstraints(constH)
        view.addConstraints(constH2)
        view.addConstraints(constH3)
        
        
        view.addConstraints(constV)
        
        
        
        header.talkTitle.text = detailObject.getTitle()
        header.talkTrack.text = detailObject.getSubTitle()
        scroll.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        scroll.text = detailObject.getSummary()
        //scroll.backgroundColor = UIColor.yellowColor()
        
        
        configure()
        
        actionButtonView2.hidden = true
        
        TalkService.sharedInstance.fetchTalks(detailObject.getRelatedIds(), completionHandler: callBack)
    }
    
    
    
    func callBack(talks : [DataHelperProtocol], error : TalksStoreError?) {
        detailObject.setRelated(talks)
        talkList.reloadData()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public override func twitter() {
        
        let originalString = detailObject.getTwitter()
     
        
        let escapedString = originalString?.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        let url = "https://twitter.com/intent/tweet?text=\(escapedString!)"
        
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    
    
    //DATASOUTCE
    
    
    
    
   
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL_10") as? ScheduleCellView
        
        if cell == nil {
            cell = ScheduleCellView(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL_10")
            
        }
        
        
        if let relatedObject = detailObject.getRelatedDetailWithIndex(indexPath.row) {
            
            
        
            cell!.leftIconView.imageView.image = relatedObject.getPrimaryImage()
            
            cell!.rightTextView.topTitleView.talkTrackName.text = "\(relatedObject.getDetailInfoWithIndex(4)?.capitalizedString ?? "") - \(relatedObject.getDetailInfoWithIndex(2) ?? "")"
            cell!.rightTextView.topTitleView.talkTitle.text = relatedObject.getTitle()
            
            cell!.rightTextView.locationView.label.text = relatedObject.getDetailInfoWithIndex(0)
            cell!.rightTextView.speakerView.label.text = relatedObject.getDetailInfoWithIndex(3)
            
            
            
            if let fav = relatedObject as? FavoriteProtocol {
                cell!.updateBackgroundColor(fav.isFav())
            }
            
        }
        
        
        
        
        
        
        cell?.accessoryType = .DisclosureIndicator
        
        return cell!
    }
    
  
    public func favorite(id : NSManagedObjectID) -> Bool {
        return SpeakerService.sharedInstance.invertFavorite(id)
    }
    
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if let talk = detailObject.getRelatedDetailWithIndex(indexPath.row) {
            
            let details = TalkDetailsController()
            details.delegate = self
            details.detailObject = talk
            
            details.configure()
            
            details.setColor(talk.isFavorited())
        
            
            self.navigationController?.pushViewController(details, animated: true)
        }
        
    }
    
    
    
    func callBackTalks(talks : [DataHelperProtocol], error : TalksStoreError?) {
        detailObject.setRelated(talks)
        talkList.reloadData()
    }
    


    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchUpdate()
        talkList.reloadData()
    }
    

    public func fetchUpdate() {
        APIReloadManager.fetchUpdate(detailObject.getFullLink(), service: SpeakerDetailService.sharedInstance, completedAction: fetchCompleted)
        
        APIReloadManager.fetchImg(detailObject.getImageFullLink(), id : detailObject.getObjectID(), service:SpeakerService.sharedInstance, completedAction: callbackImg)
    }
   
    public func fetchCompleted(newHelper : CallbackProtocol) -> Void {
    
        
        if let newDetailObject = newHelper.getHelper() as? DetailableProtocol {
            detailObject = newDetailObject
        }
        scroll.text = detailObject.getSummary()
        header.talkTrack.text = detailObject.getSubTitle()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            TalkService.sharedInstance.fetchTalks(self.detailObject.getRelatedIds(), completionHandler:self.callBackTalks)
        })
   }
    
    public func callbackImg(newHelper : CallbackProtocol) {
        if let newDetailObjectData = newHelper.getImg() {
            header.imageView.image = UIImage(data: newDetailObjectData)
        }
    }
    
   
    
    
    
    
}
