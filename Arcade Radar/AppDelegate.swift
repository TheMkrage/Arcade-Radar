//
//  AppDelegate.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 4/10/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let APP_ID = "FFA992AA-0B7F-8776-FFB4-92B410F98800"
    let SECRET_KEY = "958B8D5E-0D85-30C8-FF63-A21D5698FF00"
    let VERSION_NUM = "v1"
    func application(application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [NSObject: AnyObject]?) -> Bool {
        let backendless = Backendless.sharedInstance()
        IMSdk.initWithAccountID("cd81812d3d73471da21247c245ee8275")
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
            
        // theme this application!
        let hackerGreen = UIColor(red: 32.0/255.0, green: 194.0/255.0, blue: 14.0/255.0, alpha: 1.0)
        let sharedApplication = UIApplication.sharedApplication()
            sharedApplication.delegate?.window??.tintColor = hackerGreen
            sharedApplication.delegate?.window??.backgroundColor = UIColor.blackColor()
            UINavigationBar.appearance().tintColor = hackerGreen
            UINavigationBar.appearance().barTintColor = UIColor.blackColor()
            UINavigationBar.appearance().barStyle = .Black
            UITabBar.appearance().barTintColor = UIColor.blackColor()
            UITabBar.appearance().barStyle = .Black
            
            UISearchBar.appearance().barStyle = .Black
            UISearchBar.appearance().tintColor = hackerGreen
            UISearchBar.appearance().changeSearchBarColor(hackerGreen)
            if #available(iOS 9.0, *) {
                UILabel.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).textColor = hackerGreen
            } else {
                UILabel.appearance().textColor = hackerGreen
            }
            
            UITableView.appearance().backgroundColor = UIColor.darkGrayColor()
           // UINavigationBar.appearance().backgroundColor = UIColor.blackColor()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

// as UISearchBar extension
extension UISearchBar {
    func changeSearchBarColor(color : UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if subSubView.conformsToProtocol(UITextInputTraits.self) {
                    let textField = subSubView as! UITextField
                    textField.textColor = color
                    textField.tintColor = color
                    //textField.
                    break
                }
            }
        }
    }
}

