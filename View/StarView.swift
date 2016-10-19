//
//  StarView.swift
//  devoxxApp
//
//  Created by maxday on 06.03.16.
//  Copyright © 2016 maximedavid. All rights reserved.
//

import Foundation
import UIKit

class StarView : UITableViewCell {
    
    let star0 = UIButton()
    let star1 = UIButton()
    let star2 = UIButton()
    let star3 = UIButton()
    let star4 = UIButton()
    
    
    
    var nbStar = 0

    
    var starArray = [UIButton]()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        starArray.append(star0)
        starArray.append(star1)
        starArray.append(star2)
        starArray.append(star3)
        starArray.append(star4)
        
        for btn in starArray {
            addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let views = ["star0": star0, "star1" : star1, "star2" : star2, "star3" : star3, "star4" : star4]
        
        let width = NSLayoutConstraint(item: star0,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Width,
            multiplier: 0.2,
            constant: 0)
        
        addConstraint(width)
        
        
        
        let constH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[star0]-0-[star1(==star0)]-0-[star2(==star0)]-0-[star3(==star0)]-0-[star4]-0-|", options: .AlignAllLastBaseline, metrics: nil, views: views)
        
        let constV0 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[star0]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constV1 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[star1]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constV2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[star2]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constV3 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[star3]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constV4 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[star4]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        addConstraints(constH)
        addConstraints(constV0)
        addConstraints(constV1)
        addConstraints(constV2)
        addConstraints(constV3)
        addConstraints(constV4)
        
        for btn in starArray {
            addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            constructStar(btn)
        }
        
        clickStar(starArray[2])
        
    }
    
    func constructStar(btn : UIButton) {
        let image0 = UIImage(named: "ic_star")?.imageWithRenderingMode(.AlwaysTemplate)
        btn.setImage(image0, forState: .Normal)
        btn.tintColor = UIColor.whiteColor()
        btn.addTarget(self, action: #selector(self.clickStar(_:)), forControlEvents: .TouchUpInside)
        btn.tag = 0
    }
    
    func reset() {
        for btn in starArray {
            btn.tag = 0
            btn.tintColor = UIColor.lightGrayColor()
        }
    }
    
    func clickStar(btn : UIButton) {
        self.superview?.endEditing(true)
        reset()
        btn.tag = (btn.tag+1) % 2
        if btn.tag == 1 {
            
            var idx = 0
            var search = starArray[idx]
            
            
            
            while search != btn {
                nbStar = idx
                search.tag = 1
                search.tintColor = ColorManager.topNavigationBarColor
                idx += 1
                search = starArray[idx]
            }
            
            
            
            btn.tintColor = ColorManager.topNavigationBarColor
        }
        else {
            btn.tintColor = UIColor.lightGrayColor()
        }
        
        
    }
    
    func getSelectedStars() -> Int {
        
        var idx = 0
        for btn in starArray {
            if btn.tag == 0 {
                break
            }
            idx += 1
        }
        
        return idx
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
