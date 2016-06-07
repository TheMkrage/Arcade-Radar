//
//  ArcadeMkCircle.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 6/6/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class ArcadeMkCircle: MKCircle {
    var arcade: Arcade!
    func setArcadeToDisplay(arcade: Arcade) {
        self.arcade = arcade;
        self.title = "\(self.arcade.name)"
        self.subtitle = "Last Seen: \(self.arcade.lastSeen)"
    }

}
