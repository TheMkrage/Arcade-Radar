//
//  ArcadeTableViewController.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 5/7/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class ArcadeMachinesTableViewController: UITableViewController {
    var arcade:Arcade!
    var machines: [ArcadeMachine] = []
    var backendless = Backendless()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //checkIfNeedToSearch()
    }
    
    override func viewDidAppear(animated: Bool) {
        checkIfNeedToSearch()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        EZLoadingActivity.hide(success: true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    }

    func checkIfNeedToSearch() {
        if ((arcade) != nil) { // if given an Arcade Object
            // need add button because you are viewing from arcade
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewArcadeMachine")
            EZLoadingActivity.show("", disableUI: false)
            let queryOptions = QueryOptions()
            queryOptions.addRelated("geoPoint")
            queryOptions.sortBy = ["name"]
            //queryOptions.so
            let query = BackendlessDataQuery()
            query.queryOptions = queryOptions
            let latitude = Double(self.arcade.geoPoint!.latitude)
            let longitude = Double(self.arcade.geoPoint!.longitude)
            
            query.whereClause = "geoPoint.latitude < \(latitude + 0.002) AND geoPoint.latitude > \(latitude - 0.002) AND geoPoint.longitude > \(longitude - 0.002) AND geoPoint.longitude < \(longitude + 0.002) AND arcadeName = '\(arcade.name)'"
            
            backendless.persistenceService.of(ArcadeMachine.ofClass()).find(
                query,
                response: { ( machinesSearched : BackendlessCollection!) -> () in
                    let currentPage = machinesSearched.getCurrentPage()
                    print(machinesSearched.totalObjects)
                    if self.machines.count != currentPage.count {
                        self.machines = currentPage as! [ArcadeMachine]
                        self.tableView.reloadData()
                    }
                    EZLoadingActivity.hide(success: true, animated: true)
                },
                error: { ( fault : Fault!) -> () in
                    print("Server reported an error: \(fault)")
            })
        }else {
            print("no Tacos")
        }

    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.machines.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = self.machines[indexPath.row].name
        cell.textLabel?.textColor = Colors.hackerGreen
        // Configure the cell...
        cell.textLabel?.alpha = 0.0
        UIView.animateWithDuration(0.3, animations: {
            cell.textLabel?.alpha = 1.0
        })
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ArcadeMachineProfile") as! ArcadeMachineProfileViewController
        vc.arcadeMachine = self.machines[indexPath.row]
        self.showViewController(vc, sender: self)

    }
    
   
    func addNewArcadeMachine() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SearchForName") as! SearchForNameTableViewController
        vc.isSendingToMap = false
        vc.arcadeNameForCreating = self.arcade.name
        vc.location = CLLocationCoordinate2DMake(CLLocationDegrees(self.arcade.geoPoint!.latitude), CLLocationDegrees(self.arcade.geoPoint!.longitude))
        let nav = UINavigationController(rootViewController: vc)
        self.presentViewController(nav, animated: true, completion: nil)
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
