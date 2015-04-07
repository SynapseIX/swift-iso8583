//
//  AppDelegate.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 3/14/15.
//  Copyright (c) 2015 Jorge Tapia. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        println("***EXAMPLE OF USAGE #1***")
        
        /*
        ISOMessage *isoMessage1 = [[ISOMessage alloc] init];
        [isoMessage1 setMTI:@"0200"];
        // Declares the presence of a secondary bitmap and data elements: 3, 4, 7, 11, 44, 105
        isoMessage1.bitmap = [[ISOBitmap alloc] initWithHexString:@"B2200000001000000000000000800000"];
        
        [isoMessage1 addDataElement:@"DE03" withValue:@"123"];
        [isoMessage1 addDataElement:@"DE04" withValue:@"123"];
        [isoMessage1 addDataElement:@"DE07" withValue:@"123"];
        [isoMessage1 addDataElement:@"DE11" withValue:@"123"];
        [isoMessage1 addDataElement:@"DE44" withValue:@"Value for DE44"];
        [isoMessage1 addDataElement:@"DE105" withValue:@"This is the value for DE105"];
        
        NSString *theBuiltMessage = [isoMessage1 buildIsoMessage];
        NSLog(@"Built message:\n%@", theBuiltMessage);
        */
        
        
        let isoMessage3 = ISOMessage(isoMessage: "0200B2200000001000000000000000800000000123000000000123000000012300012314Value for DE44027This is the value for DE105")
        println("Hex bitmap 1: \(isoMessage3?.getHexBitmap1())")
        println("Bin bitmap 1: \(isoMessage3?.getBinaryBitmap1())")
        println("Hex bitmap 2: \(isoMessage3?.getHexBitmap2())")
        
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

