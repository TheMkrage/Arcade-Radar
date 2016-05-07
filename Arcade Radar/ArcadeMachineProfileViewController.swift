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
    
    @IBOutlet var scrollView: UIView!
    var arcadeMachine:ArcadeMachine = ArcadeMachine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arcadeMachineNameLabel.text = self.arcadeMachine.name
        self.lastSeenOnLabel.text = "Last Seen on \(self.arcadeMachine.lastSeen)"
        self.addressButton.setTitle(self.arcadeMachine.arcadeName, forState: .Normal)
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
