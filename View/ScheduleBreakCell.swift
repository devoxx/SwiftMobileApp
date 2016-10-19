//
//  ScheduleBreakCell.swift
//  devoxxApp
//
//  Created by got2bex on 2016-02-28.
//  Copyright © 2016 maximedavid. All rights reserved.
//


import Foundation
import UIKit
import QuartzCore

class ScheduleBreakCell : UITableViewCell {
    
    var leftIconView = LeftIconView(frame: CGRectZero)
    var rightTextView = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(leftIconView)
        addSubview(rightTextView)
        
        
        
        
        
        rightTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["leftIconView": leftIconView, "rightTextView" : rightTextView]
        
        
        let constH0 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[leftIconView(50)]-0-[rightTextView]-0-|", options: .AlignAllLastBaseline, metrics: nil, views: views)
        
        
        addConstraints(constH0)
        
        
        leftIconView.setup()
        
        
        let leftIconViewHeight = NSLayoutConstraint(item: leftIconView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1,
            constant: 0)
        
        let rightTextViewHeight = NSLayoutConstraint(item: rightTextView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1,
            constant: 0)
        
        addConstraint(leftIconViewHeight)
        addConstraint(rightTextViewHeight)
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
        
        
        
        
    }
    
    
    
    
}

