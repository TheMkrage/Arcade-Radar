//
//  NewArcadeViewController.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 6/29/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class NewArcadeViewController: ViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var nameTextField:UITextField!
    @IBOutlet var URLTextField:UITextField!
    @IBOutlet var locationTextField:UITextField!
    @IBOutlet var machineTable:UITableView!
    @IBOutlet var addMachineButton:UIButton!
    
    var isUsingCurrentLocation = true
    var machines: [ArcadeMachine] = [ArcadeMachine]()
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateWithNewArcadeMachine:", name: "ArcadeMachineAdded", object: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        self.addMachineButton.hidden = true
        
        let gestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "cancelEditing")
        self.view.addGestureRecognizer(gestureRecognizer)
        self.locationTextField.enabled = false
        // Do any additional setup after loading the view.
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelEditing() {
        self.view.endEditing(true)
    }
    
    func updateWithNewArcadeMachine(notification:NSNotification) {
        let machine = notification.userInfo!["machine"] as! ArcadeMachine
        self.machines.append(machine)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewMachine() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SearchForName") as! SearchForNameTableViewController
        vc.isSendingToMap = false
        vc.arcadeNameForCreating = self.nameTextField.text
        let nav = UINavigationController(rootViewController: vc)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    @IBAction func useCurrentLocation() {
        self.isUsingCurrentLocation = true
        self.locationTextField.enabled = false
        self.locationTextField.placeholder = "Use Current Location"
        self.locationTextField.text = "Using Current Location"
    }
    
    @IBAction func useAddress() {
        self.isUsingCurrentLocation = false
        self.locationTextField.enabled = true
        self.locationTextField.placeholder = "Address"
        self.locationTextField.text = ""
        self.locationTextField.becomeFirstResponder()
    }
    
    @IBAction func createNewArcade() {
        
    }

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.machines.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = self.machines[indexPath.row].name
        // Configure the cell...
        cell.textLabel?.alpha = 0.0
        UIView.animateWithDuration(0.3, animations: {
            cell.textLabel?.alpha = 1.0
        })
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == self.nameTextField {
            self.addMachineButton.hidden = false
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    

}
