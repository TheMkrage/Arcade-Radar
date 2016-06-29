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
    var keySeen = "machinesReportedSeen"
    var keyNotSeen = "machinesReportedNotSeen"
    var hasAlreadyReportedSeen = false
    var hasAlreadyReportedNotSeen = false
    var IDArraySeen:[NSString]!
    var IDArrayNotSeen:[NSString]!
    
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
        // Try to Read Seen Data, if not make array
        if let testArray : AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(keySeen) as? [NSString] {
            let readArray : [NSString] = testArray! as! [NSString]
            self.IDArraySeen = readArray
            for string in readArray {
                print(string)
                print((self.arcadeMachine as AnyObject).objectId)
                if string == (self.arcadeMachine as AnyObject).objectId {
                    self.hasAlreadyReportedSeen = true
                    self.yesButton.setImage(UIImage(named: "thumbsUpFilled.png"), forState: .Normal)
                }
            }
        }else {
            print("INITIAL TIME, MAKING Seen ARRAY")
            self.IDArraySeen = [NSString]()
            //save
            NSUserDefaults.standardUserDefaults().setObject(self.IDArraySeen, forKey: keySeen)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        // Try to read notSeen Data
        if let testArray : AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(keyNotSeen) as? [NSString] {
            let readArray : [NSString] = testArray! as! [NSString]
            self.IDArrayNotSeen = readArray
            for string in readArray {
                print(string)
                print((self.arcadeMachine as AnyObject).objectId)
                if string == (self.arcadeMachine as AnyObject).objectId {
                    self.hasAlreadyReportedNotSeen = true
                    self.noButton.setImage(UIImage(named: "thumbsDownFilled.png"), forState: .Normal)
                }
            }
        }else {
            print("INITIAL TIME, MAKING NotSeen ARRAY")
            self.IDArrayNotSeen = [NSString]()
            //save
            NSUserDefaults.standardUserDefaults().setObject(self.IDArrayNotSeen, forKey: keyNotSeen)
            NSUserDefaults.standardUserDefaults().synchronize()
        }

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowArcadeProfile" {
            let vc = segue.destinationViewController as! ArcadeProfileViewController
            vc.geoPointOfArcade = self.arcadeMachine.geoPoint
            vc.nameOfArcade = self.arcadeMachine.arcadeName
        }
    }
    
    func reportSeen() {
        self.arcadeMachine.finds = arcadeMachine.finds + 1
        self.hasAlreadyReportedSeen = true
        self.arcadeMachine.lastSeen = NSDate()
        self.IDArraySeen?.append((self.arcadeMachine as AnyObject).objectId)
        self.yesButton.setImage(UIImage(named: "thumbsUpFilled.png"), forState: .Normal)
    }
    
    func unreportSeen() {
        self.arcadeMachine.finds = arcadeMachine.finds - 1
        self.hasAlreadyReportedSeen = false
        self.IDArraySeen = self.IDArraySeen.filter{$0 != ((self.arcadeMachine as AnyObject).objectId)}
        self.yesButton.setImage(UIImage(named: "thumbsUpHollow.png"), forState: .Normal)
    }
    
    func reportNotSeen() {
        self.IDArrayNotSeen?.append((self.arcadeMachine as AnyObject).objectId)
        self.arcadeMachine.notFinds = self.arcadeMachine.notFinds + 1
        self.hasAlreadyReportedNotSeen = true
        self.noButton.setImage(UIImage(named: "thumbsDownFilled.png"), forState: .Normal)
    }
    
    func unreportNotSeen() {
        self.IDArrayNotSeen = self.IDArrayNotSeen.filter{$0 != ((self.arcadeMachine as AnyObject).objectId)}
        self.arcadeMachine.notFinds = self.arcadeMachine.notFinds - 1
        self.hasAlreadyReportedNotSeen = false
        self.noButton.setImage(UIImage(named: "thumbsDownHollow.png"), forState: .Normal)
    }

    @IBAction func yes(sender: AnyObject) {
        if !self.hasAlreadyReportedSeen {
            reportSeen()
            if self.hasAlreadyReportedNotSeen{
                unreportNotSeen()
            }
        }else {
            unreportSeen()
        }
        self.updateAfterNewReport()
    }
    
    @IBAction func no(sender: AnyObject) {
        if !self.hasAlreadyReportedNotSeen {
            reportNotSeen()
            if self.hasAlreadyReportedSeen{
                unreportSeen()
            }
        }else {
            unreportNotSeen()
        }
        self.updateAfterNewReport()
    }
    
    func updateAfterNewReport() {
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
        NSUserDefaults.standardUserDefaults().setObject(self.IDArraySeen, forKey: keySeen)
        NSUserDefaults.standardUserDefaults().setObject(self.IDArrayNotSeen, forKey: keyNotSeen)
        NSUserDefaults.standardUserDefaults().synchronize()
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
