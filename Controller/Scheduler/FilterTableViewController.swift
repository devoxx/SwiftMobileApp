//
//  FilterTableViewController.swift
//  devoxxApp
//
//  Created by got2bex on 2015-12-20.
//  Copyright © 2015 maximedavid. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import QuartzCore


protocol DevoxxAppFilter : NSObjectProtocol {
    func filter(filterName : [String : [FilterableProtocol]]) -> Void
}



extension Array {
    
    mutating func removeObject<U: AnyObject>(object: U) -> Element? {
        if count > 0 {
            for index in startIndex ..< endIndex {
                if (self[index] as! U) === object { return self.removeAtIndex(index) }
            }
        }
        return nil
    }
}


public class FilterTableViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    var filterTableView = FilterTableView()
    
    var selected = [String : [FilterableProtocol]]()
    
    var devoxxAppFilterDelegate:DevoxxAppFilter?
    
    var savedFetchedResult:NSFetchedResultsController!
    
    public func callBack(fetchedResult :NSFetchedResultsController?, error :AttributeStoreError?) {
        savedFetchedResult = fetchedResult
        filterTableView.reloadData()
    }
    
    
    public func fetchAll() {
        AttributeService.sharedInstance.fetchFilters(self.callBack)
    }

    
    
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        filterTableView.delegate = self
        filterTableView.dataSource = self
        self.view.addSubview(filterTableView)
        
        
        self.view.backgroundColor = ColorManager.bottomDotsPageController
        
        fetchAll()
    }
    
    
    func isFilterSelected(attribute : FilterableProtocol) -> Bool {
        if selected[attribute.filterPredicateLeftValue()] == nil  {
            return false
        }
        
        
        if let array = selected[attribute.filterPredicateLeftValue()] {
            for item in array {
                if item.filterPredicateLeftValue() == attribute.filterPredicateLeftValue() &&
                    item.filterPredicateRightValue() == attribute.filterPredicateRightValue() {
                        return true
                }
            }
        }
        
        return false
    }
    
    
    
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let track = savedFetchedResult.objectAtIndexPath(indexPath) as? Attribute {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FilterViewCell
            
            
            
            cell.userInteractionEnabled = false
            
            
            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                
                let scale = CGAffineTransformMakeScale(0.1, 0.1)
                let rotate = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                
                
                
                cell.tickedImg.transform = CGAffineTransformConcat(rotate, scale)
                }, completion: { finished in
                    
                    
                    let imageToUse = (self.isFilterSelected(track)) ? "checkboxOn" : "checkboxOff"
                    
                    cell.tickedImg.image = UIImage(named: imageToUse)
                    let scale = CGAffineTransformMakeScale(0.1, 0.1)
                    let rotate = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                    cell.tickedImg.transform = CGAffineTransformConcat(rotate, scale)
                    
                    
                    UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseOut, animations: {
                        
                        let scale = CGAffineTransformMakeScale(1, 1)
                        let rotate = CGAffineTransformMakeRotation(CGFloat(0))
                        
                        CGAffineTransformConcat(rotate, scale)
                        
                        cell.tickedImg.transform = CGAffineTransformConcat(rotate, scale)
                        }, completion: { finished in
                            
                            
                            let key = track.filterPredicateLeftValue()
                            
                            
                            if let array = self.selected[key]  {
                                var contains = false
                                
                                for item in array {
                                    if item.filterPredicateLeftValue() == track.filterPredicateLeftValue() && item.filterPredicateRightValue() == track.filterPredicateRightValue() {
                                        contains = true
                                        break
                                    }
                                }
                                
                                if contains {
                                    self.selected[key]!.removeObject(track)
                                    if self.selected[key]!.count == 0 {
                                        self.selected.removeValueForKey(key)
                                    }
                                    cell.backgroundColor = ColorManager.defaultColor
                                }
                                else {
                                    self.selected[key]!.append(track)
                                }
                                
                            }
                            else {
                                var attributeArray = [FilterableProtocol]()
                                attributeArray.append(track)
                                self.selected[key] = attributeArray
                            }
                            
                            cell.userInteractionEnabled = true
                            
                            self.devoxxAppFilterDelegate?.filter(self.selected)
                            
                            
                            
                        }
                    )
                    
                    
                }
            )
            
        }
        
        
        
        
    }
    
    
    
    
    
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL_1") as? FilterViewCell
        
        
        if cell == nil {
            cell = FilterViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL_1")
            cell?.selectionStyle = .None
            cell?.configureCell()
        }
        
        if let attribute = savedFetchedResult?.objectAtIndexPath(indexPath) as? Attribute {
            cell?.attributeTitle.text = attribute.label
            cell?.attributeImage.image = attribute.filterMiniIcon()
            
            
            
            
            
            cell?.backgroundColor = ColorManager.defaultColor
            
            let imageToUse = (isFilterSelected(attribute)) ? "checkboxOff" : "checkboxOn"
            cell?.tickedImg.image = UIImage(named: imageToUse)
            
        }
        return cell!
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = savedFetchedResult?.sections {
            return sections.count
        }
        
        return 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = savedFetchedResult?.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = savedFetchedResult?.sections {
            let currentSection = sections[section]
            if currentSection.objects?.count > 0 {
                if let currentSectionFilterable = currentSection.objects![0] as? FilterableProtocol {
                    return currentSectionFilterable.niceLabel()
                }
            }
        }
        return nil
    }
    
}