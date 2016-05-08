//
//  ArcadeMachineProfileViewController.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 4/25/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class ArcadeMachineProfileViewController: ViewController {
    @IBOutlet var arcadeMachineNameLabel: UILabel!
    @IBOutlet var lastSeenOnLabel: UILabel!
    @IBOutlet var addressButton: UIButton!
    @IBOutlet var pricePerPlayLabel: UILabel!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    @IBOutlet var yesCountLabel: UILabel!
    @IBOutlet var noCountLabel: UILabel!
    @IBOutlet var percentLabel: UILabel!
    
    @IBOutlet var scrollView: UIView!
    var arcadeMachine:ArcadeMachine = ArcadeMachine()
    var backendless = Backendless()
    var hasAlreadyReported = false
    var IDArray: [NSString]?
    let key = "machinesReported"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findIfReported()
        self.arcadeMachineNameLabel.text = self.arcadeMachine.name
        self.lastSeenOnLabel.text = "Last Seen on \(self.arcadeMachine.lastSeen)"
        self.addressButton.setTitle(self.arcadeMachine.arcadeName, forState: .Normal)
        self.yesCountLabel.text = String(format: "%7.0f", self.arcadeMachine.finds).stringByReplacingOccurrencesOfString(" ", withString: "")
        print(self.yesCountLabel.text)
        self.noCountLabel.text = String(format: "%7.0f", self.arcadeMachine.notFinds).stringByReplacingOccurrencesOfString(" ", withString: "")
        if (self.arcadeMachine.finds != 0) {
            let percent:Double = (self.arcadeMachine.finds)/(self.arcadeMachine.finds + self.arcadeMachine.notFinds)
            print(percent)
            
            self.percentLabel.text = String(format: "%3.0f%%", (percent * 100.0))
        }else {
            self.percentLabel.text = "0%"
        }
        if (self.arcadeMachine.numOfPlays > 1){
            self.pricePerPlayLabel.text = "$\(arcadeMachine.price) for \(self.arcadeMachine.numOfPlays) \(self.arcadeMachine.whatPriceIsFor)s"
        }else {
            self.pricePerPlayLabel.text = "$\(arcadeMachine.price) for \(self.arcadeMachine.numOfPlays) \(self.arcadeMachine.whatPriceIsFor)"
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findIfReported() {
        
        // Try to Read, if not make array
        if let testArray : AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(key) as? [NSString] {
            let readArray : [NSString] = testArray! as! [NSString]
            self.IDArray = readArray
            for string in readArray {
                print(string)
                print((self.arcadeMachine as AnyObject).objectId)
                if string == (self.arcadeMachine as AnyObject).objectId {
                    self.hasAlreadyReported = true
                    print("THEY ARE EQUAL")
                    self.yesButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    self.noButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                }
            }
        }else {
            print("INITIAL TIME, MAKING ARRAY")
            let array1: [NSString] = [NSString]()
            self.IDArray = array1
            //save
            NSUserDefaults.standardUserDefaults().setObject(array1, forKey: key)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        print(self.IDArray)
        
    }
    
    @IBAction func bringToMap(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ArcadeTable") as! ArcadeTableViewController
        vc.arcadeName = self.arcadeMachine.arcadeName
        self.showViewController(vc, sender: self)
    }
    
    @IBAction func yes(sender: AnyObject) {
        if !self.hasAlreadyReported {
            self.arcadeMachine.finds++
            self.arcadeMachine.lastSeen = NSDate()
            self.updateAfterNewReport()
        }
    }
    
    @IBAction func no(sender: AnyObject) {
        if !self.hasAlreadyReported {
            
            self.arcadeMachine.notFinds++
            self.updateAfterNewReport()
            
        }
    }
    
    func updateAfterNewReport() {
        self.hasAlreadyReported = true
        self.IDArray?.append((self.arcadeMachine as AnyObject).objectId)
        self.yesCountLabel.text = String(format: "%7.0f", self.arcadeMachine.finds).stringByReplacingOccurrencesOfString(" ", withString: "")
        self.noCountLabel.text = String(format: "%7.0f", self.arcadeMachine.notFinds).stringByReplacingOccurrencesOfString(" ", withString: "")
        if (self.arcadeMachine.finds != 0) {
            let percent:Double = (self.arcadeMachine.finds)/(self.arcadeMachine.finds + self.arcadeMachine.notFinds)
            print(percent)
            
            self.percentLabel.text = String(format: "%3.0f%%", (percent * 100.0))
        }else {
            self.percentLabel.text = "0%"
        }

        backendless.persistenceService.of(ArcadeMachine.ofClass()).save(self.arcadeMachine,
            response: { ( point : AnyObject!) -> Void in
                print("ASYNC: geo point saved. Object ID - \(point.objectId)")
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
            }
        )
        NSUserDefaults.standardUserDefaults().setObject(self.IDArray, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
        self.yesButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        self.noButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
