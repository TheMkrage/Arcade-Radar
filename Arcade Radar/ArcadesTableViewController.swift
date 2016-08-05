//
//  ArcadeDisplayViewControllerTableViewController.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 6/7/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class ArcadesTableViewController: UITableViewController, IMBannerDelegate {
    var banner:IMBanner?
    
    var arcades: [Arcade] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.view.bounds.height)
        self.banner = IMBanner(frame: CGRectMake(0, (self.view.bounds.height - (53 * 2)) - 49, self.view.bounds.size.width, 53), placementId: 1468459192824, delegate: self)
       // self.view.superview!.addSubview(self.banner!)
       // self.banner?.load()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ArcadeProfile") as! ArcadeProfileViewController
        vc.arcade = self.arcades[indexPath.row]
        self.showViewController(vc, sender: self)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arcades.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.textColor = Colors.hackerGreen
        cell.textLabel?.text = self.arcades[indexPath.row].name
    
        return cell
    }
    
    func banner(banner: IMBanner!, didFailToLoadWithError error: IMRequestStatus!) {
        print("Banner Load Failed")
    }
    func banner(banner: IMBanner!, didInteractWithParams params: [NSObject : AnyObject]!) {
        //print("Banner didInteractWithParams: %@",params)
    }
    func banner(banner: IMBanner!, rewardActionCompletedWithRewards rewards: [NSObject : AnyObject]!) {
        print("Banner rewardActionCompletedWithRewards %@",rewards)
    }
    func bannerDidDismissScreen(banner: IMBanner!) {
        print("bannerDidDismissScreen")
    }
    func bannerDidFinishLoading(banner: IMBanner!) {
        print("bannerDidFinishLoading")
    }
    func bannerDidPresentScreen(banner: IMBanner!) {
        print("bannerDidPresentScreen")
    }
    func bannerWillDismissScreen(banner: IMBanner!) {
        print("bannerWillDismissScreen")
    }
    func bannerWillPresentScreen(banner: IMBanner!) {
        print("bannerWillPresentScreen")
    }
    func userWillLeaveApplicationFromBanner(banner: IMBanner!) {
        print("userWillLeaveApplicationFromBanner")
    }					
				
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
