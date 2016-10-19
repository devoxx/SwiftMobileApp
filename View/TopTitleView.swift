//
//  TopTitleView.swift
//  devoxxApp
//
//  Created by got2bex on 2016-02-28.
//  Copyright © 2016 maximedavid. All rights reserved.
//

import Foundation
import UIKit

class TopTitleView : UIView {
    
    let talkTrackName = UILabel()
    //let talkTitle = UITextView()
    let talkTitle = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .ScaleAspectFill
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        //backgroundColor = UIColor.yellowColor()
        
        
        
        talkTrackName.font = UIFont(name: "Roboto", size: 15)
        talkTrackName.textColor = ColorManager.darkOrangeColor
        talkTitle.font = UIFont(name: "Roboto", size: 17)
        //talkTitle.contentInset = UIEdgeInsetsMake(-6,-4,0,0);
        //talkTitle.userInteractionEnabled = false
        talkTitle.numberOfLines = 0
        
        talkTitle.translatesAutoresizingMaskIntoConstraints = false
        talkTrackName.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(talkTitle)
        addSubview(talkTrackName)
        
        let views = ["talkTitle": talkTitle, "talkTrackName" : talkTrackName]
        
        
        let constH0 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[talkTitle]-0-|", options: .AlignAllLastBaseline, metrics: nil, views: views)
        let constH1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[talkTrackName]-0-|", options: .AlignAllLastBaseline, metrics: nil, views: views)
        
        let constV0 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[talkTrackName]-0-[talkTitle]-0-|", options: .AlignAllCenterX, metrics: nil, views: views)
        
        
        addConstraints(constH0)
        addConstraints(constH1)
        addConstraints(constV0)
        
        
        let talkTrackNameHeight = NSLayoutConstraint(item: talkTrackName,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Height,
            multiplier: 0.3,
            constant: 0)
        
        
        let talkTitleHeight = NSLayoutConstraint(item: talkTitle,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Height,
            multiplier: 0.7,
            constant: 0)
        
        
        
        addConstraint(talkTitleHeight)
        addConstraint(talkTrackNameHeight)
        
        //talkTitle.backgroundColor = UIColor.purpleColor()
        //talkTrackName.backgroundColor = UIColor.grayColor()
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
