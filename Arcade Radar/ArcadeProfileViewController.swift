//
//  ArcadeProfileViewController.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 6/7/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class ArcadeProfileViewController: ViewController {
    var keySeen = "arcadesReportedSeen"
    var keyNotSeen = "arcadesReportedNotSeen"
    var hasAlreadyReportedSeen = false
    var hasAlreadyReportedNotSeen = false
    var IDArraySeen:[NSString]!
    var IDArrayNotSeen:[NSString]!
    var arcade:Arcade!
    var nameOfArcade:String?
    var geoPointOfArcade:GeoPoint?
    var backendless = Backendless.sharedInstance()
    @IBOutlet var arcadeLabel: UILabel!
    @IBOutlet var lastSeenLabel: UILabel!
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet var yesCountLabel: UILabel!
    @IBOutlet var noCountLabel: UILabel!
    
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((self.nameOfArcade?.isEmpty) != nil) {
            findArcade()
            findIfReported()
        }else {
            findIfReported()
        }
        if self.arcade.URL.isEmpty {
            self.bringToWebsiteButton.hidden = true
        }
        self.arcadeLabel.text = self.arcade.name
        self.lastSeenLabel.text = "Last Seen on \(self.arcade.lastSeen)"
        self.yesCountLabel.text = "\(self.arcade.finds)"
        self.noCountLabel.text = "\(self.arcade.notFinds)"
        if (self.arcade.finds != 0) {
            let percent:Double = Double(self.arcade.finds)/(Double(self.arcade.finds) + Double(self.arcade.notFinds))
            self.percentLabel.text = String(format: "%3.0f%%", (percent * 100.0))
        }else {
            self.percentLabel.text = "0%"
        }
    }
    
    func findIfReported() {
        // Try to Read Seen Data, if not make array
        if let testArray : AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(keySeen) as? [NSString] {
            let readArray : [NSString] = testArray! as! [NSString]
            self.IDArraySeen = readArray
            for string in readArray {
               // print(string)
                //print((self.arcade as AnyObject).objectId)
                if string == (self.arcade as AnyObject).objectId {
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
                //print(string)
               // print((self.arcade as AnyObject).objectId)
                if string == (self.arcade as AnyObject).objectId {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var bringToWebsiteButton: UIButton!
    @IBAction func bringToWebsite(sender: AnyObject) {
        if !UIApplication.sharedApplication().openURL(NSURL(string:self.arcade.URL)!) {
            if !UIApplication.sharedApplication().openURL(NSURL(string:"https://www.\(self.arcade.URL)")!) {
                UIApplication.sharedApplication().openURL(NSURL(string:"https://\(self.arcade.URL)")!)
            }
        }
    }
    
    @IBAction func bringToMapButton(sender: AnyObject) {
        if let x = (self.navigationController?.viewControllers[0] as? MapViewController){
            x.startingGeoPoint = self.arcade.geoPoint
        }else {
            self.tabBarController?.selectedIndex = 0
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func bringToArcadeGames(sender: UIButton) {
        let vc = ArcadeMachinesTableViewController()
       // vc.arcade = self.arcade
        vc.arcade = self.arcade
        self.showViewController(vc, sender: self)
        
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func reportSeen() {
        let finds = self.arcade.finds
        self.arcade.finds = finds.floatValue + 1
        self.hasAlreadyReportedSeen = true
        self.arcade.lastSeen = NSDate()
        self.IDArraySeen?.append((self.arcade as AnyObject).objectId)
        self.yesButton.setImage(UIImage(named: "thumbsUpFilled.png"), forState: .Normal)
    }
    
    func unreportSeen() {
        self.arcade.finds = arcade.finds.floatValue - 1
        self.hasAlreadyReportedSeen = false
        self.IDArraySeen = self.IDArraySeen.filter{$0 != ((self.arcade as AnyObject).objectId)}
        self.yesButton.setImage(UIImage(named: "thumbsUpHollow.png"), forState: .Normal)
    }
    
    func reportNotSeen() {
        self.IDArrayNotSeen?.append((self.arcade as AnyObject).objectId)
        self.arcade.notFinds = self.arcade.notFinds.floatValue + 1
        self.hasAlreadyReportedNotSeen = true
        self.noButton.setImage(UIImage(named: "thumbsDownFilled.png"), forState: .Normal)
    }
    
    func unreportNotSeen() {
        self.IDArrayNotSeen = self.IDArrayNotSeen.filter{$0 != ((self.arcade as AnyObject).objectId)}
        self.arcade.notFinds = self.arcade.notFinds.floatValue - 1
        self.hasAlreadyReportedNotSeen = false
        self.noButton.setImage(UIImage(named: "thumbsDownHollow.png"), forState: .Normal)
    }
    @IBAction func yesButton(sender: AnyObject) {
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
    @IBAction func noButton(sender: AnyObject) {
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
        
        self.yesCountLabel.text = "\(self.arcade.finds)"
        self.noCountLabel.text = "\(self.arcade.notFinds)"
        if (self.arcade.finds != 0) {
            let percent:Double = (Double(self.arcade.finds))/(Double(self.arcade.finds) + Double(self.arcade.notFinds))
            print(percent)
            
            self.percentLabel.text = String(format: "%3.0f%%", (percent * 100.0))
            self.lastSeenLabel.text = "Last seen on \(self.arcade.lastSeen)"
        }else {
            self.percentLabel.text = "0%"
        }
        
        print("Before changing anything, here is my finds: \(self.arcade.finds)")
        print("Here is my object ID: \(self.arcade.objectId)")
        
        // Time to update the value
        backendless.data.save(self.arcade, response: { (x:AnyObject!) -> Void in
             print("Arcade has been updated. Finds now: \(x.finds)")
            }, error: { (error:Fault!) -> Void in
                print("Server reported an error (2): \(error)")
        })
       /* backendless.persistenceService.save(self.arcade,
            response: { ( point : AnyObject!) -> Void in
                print("ASYNC: geo point saved. Object ID - \(point.objectId)")
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
            }
        )*/
        NSUserDefaults.standardUserDefaults().setObject(self.IDArraySeen, forKey: keySeen)
        NSUserDefaults.standardUserDefaults().setObject(self.IDArrayNotSeen, forKey: keyNotSeen)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func findArcade() {
        print("Finding Arcade")
        let queryOptions = QueryOptions()
        queryOptions.addRelated("geoPoint")
        queryOptions.pageSize = 1
        //queryOptions.so
        let query = BackendlessDataQuery()
        query.queryOptions = queryOptions
        let gp = self.geoPointOfArcade
        let latitude = Double(gp!.latitude)
        let longitude = Double(gp!.longitude)
        print(self.nameOfArcade)
        print(self.geoPointOfArcade)
        query.whereClause = "distance( \(latitude), \(longitude), geoPoint.latitude, geoPoint.longitude ) < 40 AND name LIKE '\(self.nameOfArcade!)'"
        print(query.whereClause)
        Types.tryblock({ () -> Void in
             let arcadesSearched: BackendlessCollection! = self.backendless.data.of(Arcade.ofClass()).find(query)
            self.arcade = arcadesSearched.getCurrentPage()[0] as! Arcade
            }, catchblock: { (exception) -> Void in
                print(exception)
        })
    }
}
