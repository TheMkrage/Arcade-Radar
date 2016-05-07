
//
//  ArcadeMachineMkCircle.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 5/7/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class ArcadeMachineMkCircle: MKCircle {
    var machine: ArcadeMachine?
    func setArcadeMachine(machine: ArcadeMachine) {
        self.machine = machine;
        self.title = "\(machine.name)"
        self.subtitle = "Last Seen: \(machine.lastSeen)"
    }
    
}
