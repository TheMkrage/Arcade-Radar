//
//  ArcadeMachine.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 4/24/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class ArcadeMachine: MKCircle {
    var name = ""
    var lastSeen = NSDate()
    var geoPoint = "" // This should be something that can hold a lat and long
    var address = "" // Address object
    var price = 1.00 // In US Dollars
    var whatPriceIsFor = "plays" // songs/lives/plays etc.
    var finds  = 0 // How many people have found and played this machine
    var notFinds = 0// How many people could not find this machine
    var latestComment = ""  // 50 character max
}
