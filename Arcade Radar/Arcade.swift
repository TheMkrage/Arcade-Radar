//
//  Arcade.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 6/6/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class Arcade: NSObject {
    var name:String!
    var objectId:String!
    var finds:NSNumber!
    var notFinds:NSNumber!
    var lastSeen = NSDate()
    var geoPoint:GeoPoint? // This should be something that can hold a lat and long
    var URL:String!
    
}
