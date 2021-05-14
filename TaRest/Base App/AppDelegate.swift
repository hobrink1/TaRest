//
//  AppDelegate.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 11.05.21.
//

import UIKit


// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - System Wide Constants
// -------------------------------------------------------------------------------------------------
let VersionLabel: String = "V0.0.3"


// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - App Delegate
// -------------------------------------------------------------------------------------------------

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /**
     -----------------------------------------------------------------------------------------------
     
     didFinishLaunchingWithOptions:
     
     -----------------------------------------------------------------------------------------------
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // restore the userDefaults
        GlobalData.unique.restoreGlobalData()
        
        // start error list system
        ErrorList.unique.establishErrorList()
        
        // start Restaurant data
        RestaurantData.unique.startRestaurantData()
        
        
        return true
    }

    
    
    // -------------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: UISceneSession Lifecycle
    // -------------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     configurationForConnecting:
     
     -----------------------------------------------------------------------------------------------
     */
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /**
     -----------------------------------------------------------------------------------------------
     
     didDiscardSceneSessions:
     
     -----------------------------------------------------------------------------------------------
     */
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

