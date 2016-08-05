//
//  ArcadeMachineTableViewCell.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 5/7/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class ArcadeMachineTableViewCell: UITableViewCell {

    @IBOutlet var pricePerPlayLabel: UILabel!
    @IBOutlet var machineNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let hackerGreen = UIColor(red: 32.0/255.0, green: 194.0/255.0, blue: 14.0/255.0, alpha: 1.0)
        pricePerPlayLabel.textColor = hackerGreen
        machineNameLabel.textColor = hackerGreen
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
