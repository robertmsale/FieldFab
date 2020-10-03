//
//  AppDelegate.swift
//  FieldFab
//
//  Created by Robert Sale on 9/4/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var al: AppLogic?
    var db: DB?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        al = AppLogic()
        db = DB()
        
        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(
            rootView:
                contentView
                .environmentObject(al!)
                .environmentObject(db!)
        )
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        if let scheme = url.scheme,
           scheme.localizedCaseInsensitiveCompare("fieldfab") == .orderedSame,
           let view = url.host {
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            if view == "load" {
                al!.sessionName = parameters["name"] ?? "Ductwork"
                al!.width = Fraction(NumberFormatter().number(from: parameters["width"] ?? "16")?.floatValue.cg ?? 16)
                al!.depth = Fraction(NumberFormatter().number(from: parameters["depth"] ?? "20")?.floatValue.cg ?? 20)
                al!.length = Fraction(NumberFormatter().number(from: parameters["length"] ?? "5")?.floatValue.cg ?? 5)
                al!.offsetX = Fraction(NumberFormatter().number(from: parameters["offsetX"] ?? "1")?.floatValue.cg ?? 1)
                al!.offsetY = Fraction(NumberFormatter().number(from: parameters["offsetY"] ?? "0")?.floatValue.cg ?? 0)
                al!.tWidth = Fraction(NumberFormatter().number(from: parameters["tWidth"] ?? "20")?.floatValue.cg ?? 20)
                al!.tDepth = Fraction(NumberFormatter().number(from: parameters["tDepth"] ?? "16")?.floatValue.cg ?? 16)
                al!.isTransition = parameters["isTransition"] == "true" ? true : false
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

