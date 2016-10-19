//
//  SelectionWheel.swift
//  devoxxApp
//
//  Created by got2bex on 2016-02-27.
//  Copyright © 2016 maximedavid. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol SelectionWheelDatasource {
    func imageForSliceAtIndex(index:Int) -> UIImage
}

protocol SelectionWheelDelegate {
    func updateIndex(index:Int)
}

class SelectionWheel: UIView {
    
    var layers = [CAShapeLayer]()
    var imgViews = [UIImageView]()
    var currentIndex = -1
    var orig : CGAffineTransform!
    
    var globe : UIImageView!
    
    var datasource : SelectionWheelDatasource!
    var delegate : SelectionWheelDelegate!
    
    func rotate90() {
        transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        orig = transform
    }
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        
        //backgroundColor = UIColor.blueColor()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.check(_:)))
        addGestureRecognizer(tap)
        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func check(sender : UITapGestureRecognizer) {
        let point = sender.locationInView(self)
        var i = 0
        
        for shape in layers {
            
            if CGPathContainsPoint(shape.path!, nil, point, false) {
                click(i)
                return
            }
            i += 1
        }
    }
    
    
    func createCenterCircle(center : CGPoint, radius : CGFloat, color : UIColor, angle : CGFloat, index: Int)  -> CAShapeLayer {
        return createCircle(center, radius: radius, color: color, angle : angle, index : index, isCenter : true)
    }
    
    func createEventCircle(center : CGPoint, radius : CGFloat, color : UIColor, angle : CGFloat, index : Int)  -> CAShapeLayer {
        return createCircle(center, radius: radius, color: color, angle : angle, index : index, isCenter : false)
    }
    
    
    
    func createCircle(center : CGPoint, radius : CGFloat, color : UIColor, angle : CGFloat, index : Int, isCenter : Bool) -> CAShapeLayer {
        
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        
        
        
        
        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath
        
        
        
        
        if !isCenter {
            
            
            shapeLayer.anchorPoint = CGPointMake(0.5, 0.5)
            
            
            
            let image = datasource.imageForSliceAtIndex(index)
            
            
            
            let imgV = UIImageView(frame : CGRectMake(0,0, 159/2, 191/2))
            imgV.image = image
            
            
            
            addSubview(imgV)
            
            
            shapeLayer.fillColor = UIColor.clearColor().CGColor
            
            
            
            /*
            let scale = CGAffineTransformMakeScale(0.1, 0.1)
            let rotate = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            cell.tickedImg.transform = CGAffineTransformConcat(rotate, scale)
            */
            
            
            let rotate = CGAffineTransformMakeRotation(CGFloat(M_PI_2) + angle)
            
            imgV.center = CGPointMake(circlePath.bounds.midX + cos(angle) * 10, circlePath.bounds.midY + sin(angle) * 10)
            
            imgV.transform = rotate
            
            imgViews.append(imgV)
            layers.append(shapeLayer)
            
        }
            
        else {
            
            
            shapeLayer.fillColor = color.CGColor
            
            
        }
        shapeLayer.strokeColor = UIColor.clearColor().CGColor
        
        return shapeLayer
        
    }
    
    
    
    func reset() {
        
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        
    }
    
    func setup() {
        
        reset()
        
        let radius = min((frame.size.width - 150)/2, 200)
        
        
        let centerPoint = CGPointMake(center.x - frame.origin.x, center.y - self.frame.origin.y)
        
        layer.addSublayer(createCenterCircle(centerPoint, radius: radius, color : ColorManager.centerWheelColor, angle: 0, index: 0))
        
        
        let width = radius - 25
        globe = UIImageView(frame: CGRectMake(0, 0, width*2, width*2))
        globe.center = centerPoint
        globe.image = UIImage(named: "globe")
        
        addSubview(globe)
        
        
        for i in 0...4 {
            
            
            
            let a:CGFloat = CGFloat(M_PI)
            let b:CGFloat = CGFloat(2)
            let fakeC = CGFloat(i)/5.0
            let c:CGFloat = CGFloat(fakeC)
            
            
            let firstPoint = CGPointMake(centerPoint.x + radius*cos(CGFloat(a*b*c)), centerPoint.y + radius*sin(CGFloat(a*b*c)))
            
            
            
            layer.addSublayer(createEventCircle(firstPoint, radius: CGFloat(191/4), color : UIColor.greenColor(), angle : a*b*c, index: i))
            
        }
        
        
        
        
        
        
        
        
        
        rotate90()
        
    }
    
    func click(index : Int) {
        
        if(currentIndex == index)  {
            return
        }
        
        
        
        let oneSlice = CGFloat(-M_PI) * CGFloat(2) / CGFloat(layers.count)
        let diff = CGFloat(index)
        
        
        
        let rotate = CGAffineTransformMakeRotation(diff*oneSlice)
        
        UIView.animateWithDuration(0.3, animations: {
            
            let r = CGAffineTransformConcat(self.orig, rotate)
            
            if self.currentIndex != -1 {
                let zoomCurrent = CGAffineTransformMakeScale(1/1.4, 1/1.4)
                let saveTransformCurrent = self.imgViews[self.currentIndex].transform
                self.imgViews[self.currentIndex].transform = CGAffineTransformConcat(saveTransformCurrent, zoomCurrent)
            }
            
            let zoom = CGAffineTransformMakeScale(1.4, 1.4)
            let saveTransform = self.imgViews[index].transform
            self.imgViews[index].transform = CGAffineTransformConcat(saveTransform, zoom)
            
            self.transform = r
        })
        
        currentIndex = index
        
        delegate.updateIndex(currentIndex)
        
    }
    
}
