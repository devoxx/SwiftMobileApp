//
//  ScheduleCellView.swift
//  devoxxApp
//
//  Created by got2bex on 2016-02-28.
//  Copyright © 2016 maximedavid. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class ScheduleCellView: UITableViewCell {
    
    var leftIconView = LeftIconView(frame: CGRectZero)
    var rightTextView = RightTextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(leftIconView)
        addSubview(rightTextView)
        
        let views = ["leftIconView": leftIconView, "rightTextView" : rightTextView]
        
        
        let constH0 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[leftIconView(50)]-0-[rightTextView]-0-|", options: .AlignAllLastBaseline, metrics: nil, views: views)
        
        let constV0 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[leftIconView]-0-|", options: .AlignAllCenterX, metrics: nil, views: views)
        
        let constV1 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[rightTextView]-0-|", options: .AlignAllCenterX, metrics: nil, views: views)
        
        addConstraints(constH0)
        addConstraints(constV0)
        addConstraints(constV1)
        
        leftIconView.setup()
        
        
    }
    
    
    func updateBackgroundColor(isFavorited : Bool) {
        if(isFavorited) {
            backgroundColor = ColorManager.favoriteBackgroundColor
        }
        else {
            backgroundColor = UIColor.whiteColor()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
        
        
        
        
    }
    
    
    
    
}

