//
//  ArcadeProfileViewController.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 6/7/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class ArcadeProfileViewController: ViewController {
    var key = "arcadesReported"
    var hasAlreadyReported = false
    var IDArray:[NSString]!
    var arcade:Arcade!
    var nameOfArcade:String?
    var geoPointOfArcade:GeoPoint?
    var backendless = Backendless()
    @IBOutlet var arcadeLabel: UILabel!
    @IBOutlet var lastSeenLabel: UILabel!
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet var yesCountLabel: UILabel!
    @IBOutlet var noCountLabel: UILabel!
    
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        findIfReported()
        if ((self.nameOfArcade?.isEmpty) != nil) {
            findArcade()
        }
        if self.arcade.URL.isEmpty {
            self.bringToWebsiteButton.hidden = true
        }
        self.arcadeLabel.text = self.arcade.name
        self.lastSeenLabel.text = "Last Seen on \(self.arcade.lastSeen)"
        self.yesCountLabel.text = String(format: "%7.0f", self.arcade.finds).stringByReplacingOccurrencesOfString(" ", withString: "")
        self.noCountLabel.text = String(format: "%7.0f", self.arcade.notFinds).stringByReplacingOccurrencesOfString(" ", withString: "")
        if (self.arcade.finds != 0) {
            let percent:Double = (self.arcade.finds)/(self.arcade.finds + self.arcade.notFinds)
            self.percentLabel.text = String(format: "%3.0f%%", (percent * 100.0))
        }else {
            self.percentLabel.text = "0%"
        }
    }
    
    func findIfReported() {
        // Try to Read, if not make array
        if let testArray : AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(key) as? [NSString] {
            let readArray : [NSString] = testArray! as! [NSString]
            self.IDArray = readArray
            for string in readArray {
                print(string)
                print((self.arcade as AnyObject).objectId)
                if string == (self.arcade as AnyObject).objectId {
                    self.hasAlreadyReported = true
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var bringToWebsiteButton: UIButton!
    @IBAction func bringToWebsite(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:self.arcade.URL)!)
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
    func findArcade() {
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
        query.whereClause = "distance( \(latitude), \(longitude), geoPoint.latitude, geoPoint.longitude ) < .006 AND name LIKE '\(self.nameOfArcade!)'"
        Types.tryblock({ () -> Void in
             let arcadesSearched: BackendlessCollection! = self.backendless.data.of(Arcade.ofClass()).find(query)
            self.arcade = arcadesSearched.getCurrentPage()[0] as! Arcade
            }, catchblock: { (exception) -> Void in
                print(exception)
        })
    }
}
