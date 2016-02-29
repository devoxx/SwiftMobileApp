//
//  ViewController.swift
//  MDRotatingPieChart
//
//  Created by Maxime DAVID on 2015-04-03.
//  Copyright (c) 2015 Maxime DAVID. All rights reserved.
//

import UIKit




class ViewController: UIViewController, SelectionWheelDatasource, SelectionWheelDelegate {
    
    var slicesData:NSArray!
  
    let wheelView = SelectionWheel()
    
    let color = UIColor(red: 255/255, green: 152/255, blue: 0/255, alpha: 1)
    let tabController = UITabBarController()
    var currentSelectedIndex = 0
    var imgView:UIImageView!
    var globeView:UIView!
    var eventLocation:UILabel!
    var rotating = false

    func generateScheduleTableViewController() -> ScrollableDateProtocol {
        return SchedulerTableViewController()
    }
    
    func generate() -> ScrollableItemProtocol {
        return MapController()
    }
    
    
    
    func run_on_background_thread(code: () -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), code)
    }
    
    func run_on_main_thread(code: () -> Void) {
        dispatch_async(dispatch_get_main_queue(), code)
    }
    
    

    
    func rotateOnce() {
      
        UIView.animateWithDuration(1.0,
            delay: 0.0,
            options: .CurveLinear,
            animations: {
                self.globeView.transform = CGAffineTransformRotate(self.globeView.transform, 3.1415926)
            },
            completion: {finished in self.rotateAgain()})
    }
    
    func rotateAgain() {
        UIView.animateWithDuration(1.0,
            delay: 0.0,
            options: .CurveLinear,
            animations: {
                                    self.globeView.transform = CGAffineTransformRotate(self.globeView.transform, 3.1415926)
            },
            completion: {finished in if self.rotating { self.rotateOnce() }})
    }
    
    func prepareNext() {
        
       rotating = true
       rotateOnce()
        
        
        
        
        
        run_on_background_thread
            {
                
                
                
                APIManager.setEvent(self.slicesData.objectAtIndex(self.currentSelectedIndex) as! Cfp)
                
                
                APIManager.eventFeed()
                
                
                
                self.run_on_main_thread
                    {
                    self.rotateOnce()
                        if(APIManager.isCurrentEventEmpty()) {
                            let alert = UIAlertController(title: "No data", message: "No data for this event, select Belgium to test", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: nil))
                            self.rotating = false
                            self.presentViewController(alert, animated: true, completion: nil)
                            return
                        }
                        
                        
                        let scheduleController = ScheduleController<SchedulerTableViewController>(generator:self.generateScheduleTableViewController)
                        let speakerController = SpeakerTableController()
                        let mapController = MapTabController()
                        
                        let scheduleTabImage = UIImage(named: "tabIconSchedule.png")
                        let speakerTabImage = UIImage(named: "tabIconSpeaker.png")
                        let mapTabImage = UIImage(named: "tabIconMap.png")
                        
                        scheduleController.tabBarItem = UITabBarItem(title: "Schedule", image: scheduleTabImage, tag:0)
                        speakerController.tabBarItem = UITabBarItem(title: "Speakers", image: speakerTabImage, tag:1)
                        mapController.tabBarItem = UITabBarItem(title: "Map", image: mapTabImage, tag:2)
                        
                        //let scheduleNavigationController = UINavigationController(rootViewController: scheduleController)
                        let speakerNavigationController = UINavigationController(rootViewController: speakerController)
                        
                        
                        
                        
                        //let scroll = GenericPageScrollController<MapController>(generator:generate)
                        
                        let mapNavigationController = UINavigationController(rootViewController: mapController)
                        
                        
                        self.tabController.viewControllers = [scheduleController, speakerNavigationController, mapNavigationController]
                        self.tabController.tabBar.translucent = false
                        self.tabController.view.backgroundColor = UIColor.whiteColor()
                        //TODO BACK BUTTON
                        //self.navigationController?.navigationBarHidden = false
                        
                        self.addChildViewController(self.tabController)
                        self.view.addSubview(self.tabController.view)
                        
                        self.rotating = false
                        self.navigationController?.pushViewController(self.tabController, animated: true)
                        

                }
        }
        
        
        
        
        
        
        
        
        //selectedEvent
        

    }
    
    func remove() {
        tabController.view.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        slicesData = APIManager.getAllEvents()
        
        imgView = UIImageView()
        imgView.contentMode = .ScaleAspectFit
        
        
        
        self.view.addSubview(imgView)
        
        let headerView = HomeHeaderView()
        
        let goView = HomeGoButtonView()
        let numberView = HomeNumberView()

        
        eventLocation = headerView.eventLocation
        
        view.addSubview(headerView)
        view.addSubview(wheelView)
        view.addSubview(goView)
        view.addSubview(numberView)
        
        
        let viewsDictionary = ["headerView":headerView, "wheelView":wheelView, "goView":goView, "numberView":numberView]
        
        let layout = NSLayoutFormatOptions(rawValue: 0)
        
        let horizontalContraint0:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[headerView]-0-|", options: layout, metrics: nil, views: viewsDictionary)
        let horizontalContraint1:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[wheelView]-0-|", options: layout, metrics: nil, views: viewsDictionary)
        let horizontalContraint2:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[goView]-0-|", options: layout, metrics: nil, views: viewsDictionary)
        let horizontalContraint3:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[numberView]-0-|", options: layout, metrics: nil, views: viewsDictionary)
        
        
        let v1 = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 0.15, constant: 0)
        let v2 = NSLayoutConstraint(item: wheelView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 0.6, constant: 0)
        let v3 = NSLayoutConstraint(item: goView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 0.1, constant: 0)
        let v4 = NSLayoutConstraint(item: numberView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 0.15, constant: 0)
      
        
        let verticalContraint:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[headerView]-0-[wheelView]-0-[goView]-0-[numberView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        
        self.view.addConstraints(horizontalContraint0)
        self.view.addConstraints(horizontalContraint1)
        self.view.addConstraints(horizontalContraint2)
        self.view.addConstraints(horizontalContraint3)
        
        self.view.addConstraints(verticalContraint)
        
        
        self.view.addConstraint(v1)
        self.view.addConstraint(v2)
        self.view.addConstraint(v3)
        self.view.addConstraint(v4)
        
    
        numberView.applyConstraint()
        
        
        
        
        
        
        
        
        
        
        
      //  wheelView.setConstraints()
        
               
        //wheelView.pieChart.datasource = self
        //wheelView.pieChart.delegate = self
        
        
        view.layoutIfNeeded()
        wheelView.layoutIfNeeded()
        
        
        
        
        
        
        
        
        
       
       // print(wheelView.pieChart.frame)
      //  let point = self.wheelView.convertPoint(wheelView.pieChart.center, toView: wheelView)
       // print(point)
       // let point2 = CGPointMake(point.x-wheelView.pieChart.frame.origin.x, point.y-wheelView.pieChart.frame.origin.y)
       // print(point2)
        
       // wheelView.pieChart.build(point2)
        
      

               
        goView.goButton.addTarget(self, action: Selector("prepareNext"), forControlEvents: .TouchUpInside)
        
        
        wheelView.datasource = self
        wheelView.delegate = self
      
        wheelView.setup()
        globeView = wheelView.globe
        updateIndex(currentSelectedIndex)
    }
    
     
    
    
 
    
    //Delegate
    //some sample messages when actions are triggered (open/close slices)
    func didOpenSliceAtIndex(index: Int) {
        print("Open slice at \(index)")
    }
    
    func didCloseSliceAtIndex(index: Int) {
        print("Close slice at \(index)")
    }
    
    func willOpenSliceAtIndex(index: Int) {
        
        
    }
    
    func willCloseSliceAtIndex(index: Int) {
        print("Will close slice at \(index)")
    }
    
    //Datasource
    func colorForSliceAtIndex(index:Int) -> UIColor {
        return color
    }
    
    func valueForSliceAtIndex(index:Int) -> CGFloat {
        return CGFloat(100/slicesData.count)
    }
    
    func numbersForSliceAtIndex(index:Int) -> Array<Int> {
        if let currentData = slicesData[index] as? EventProtocol {
            return currentData.numbers()
        }
        return [0,0,0]
    }
    
    func labelForSliceAtIndex(index:Int) -> String {
        if let currentData = slicesData[index] as? EventProtocol {
            return currentData.title()
        }
        return ""
    }
    
    func imageForSliceAtIndex(index:Int) -> UIImage {
        if let currentData = slicesData[index] as? EventProtocol {
            return UIImage(named: currentData.splashImageName())!
        }
        //TODO
        return UIImage(named: "sample.png")!
    }
    
    func numberOfSlices() -> Int {
        return slicesData.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateIndex(index:Int) {
        currentSelectedIndex = index
        if let currentData = slicesData[index] as? EventProtocol {
            let img = UIImage(data: currentData.backgroundImage())
            let tmpImageView = UIImageView(image: img)
            imgView.image = img
            imgView.frame = tmpImageView.frame
            eventLocation.text = currentData.title()
        }
        currentSelectedIndex = index
    }
}


