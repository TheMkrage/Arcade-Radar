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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func bringToMap(sender: AnyObject) {
    }

    @IBAction func yes(sender: AnyObject) {
    }
    
    @IBAction func no(sender: AnyObject) {
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
