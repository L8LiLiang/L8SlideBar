//
//  AppDelegate.swift
//  L8SlideBar
//
//  Created by Chuanxun on 16/3/14.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.makeKeyAndVisible()
        
        let controller = L8SlideBarController(titleViewHeight: 32, statusIndicateLineHeight: 2)
        controller.titles = ["头条","圈子","集锦","中超","深度","足彩","专题","闲情","英超","装备"]
        controller.showStatusIndicateLine = true
        controller.titleViewItemWidth = 80
        controller.statusIndicateLineWidth = 60
        controller.titleFont = UIFont.systemFontOfSize(14)
        
        for i in 0..<10 {
            let ctl = TestController(nibName: nil, bundle: nil)
            ctl.view.backgroundColor = randomColor()
            ctl.titleDesc = "\(i)"
            controller.controllers.append(ctl)
        }
        
        
        self.window?.rootViewController = controller
        
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

func randomColor()->UIColor{
    
    let red = CGFloat(arc4random_uniform(256))/255.0
    let green = CGFloat(arc4random_uniform(256))/255.0
    let blue = CGFloat(arc4random_uniform(256))/255.0
    //    srand48(Int(time(nil)))
    //    let alpha = drand48() // 0.396464773760275
    //    print("\(red,green,blue)")
    return UIColor(red: red, green: green, blue: blue, alpha: 1)
}

