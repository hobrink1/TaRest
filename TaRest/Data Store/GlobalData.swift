//
//  GlobalData.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 12.05.21.
//

import Foundation
import UIKit
import MapKit


// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Class
// -------------------------------------------------------------------------------------------------
final class GlobalData: NSObject {
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Singleton
    // ---------------------------------------------------------------------------------------------
    static let unique = GlobalData()
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Data Queue
    // ---------------------------------------------------------------------------------------------

    // we use a queue to manage the data. This provides us from data races. The queue is concurrent,
    // so many can read at the same time, but only one can write
    public let DataQueue : DispatchQueue = DispatchQueue(
        label: "org.hobrink.TaRest.GlobalDataQueue",
        qos: .userInitiated, attributes: .concurrent)

    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Constants
    // ---------------------------------------------------------------------------------------------
    // just a shortcall for the UserDefaults()
    private let permanentStore = UserDefaults.standard
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Variables, NOT permanently stored
    // ---------------------------------------------------------------------------------------------

    public var LocationServceAllowed : Bool = false
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Variables, permanently stored
    // ---------------------------------------------------------------------------------------------
    // This is the selcted tab from MainTabBarController()
    public var UIMainTabBarSelectedTab: Int = 0 {
        
        didSet { self.DataQueue.async(flags: .barrier, execute: {
            self.permanentStore.set(self.UIMainTabBarSelectedTab,
                                    forKey: "TaRest.UIMainTabBarSelectedTab")
        }) }
    }
    
    // This is the current sort strategy of ListTableViewController()
    public var UIListTableViewSortStrategy: Int = 0 {
        
        didSet { self.DataQueue.async(flags: .barrier, execute: {
            self.permanentStore.set(self.UIListTableViewSortStrategy,
                                    forKey: "TaRest.UIListTableViewSortStrategy")
        }) }
    }
    

    
    // we restore the last map region. Initially we show whole Berlin.
    // The values for center and span have been taken from a real device
    public var UIMapLastCenterCoordinate: CLLocationCoordinate2D =
        CLLocationCoordinate2D(latitude: 52.453730238865944,
                               longitude: 13.445109940799426) {
        
        didSet { self.DataQueue.async(flags: .barrier, execute: {
            self.permanentStore.set(self.UIMapLastCenterCoordinate.latitude,
                                    forKey: "TaRest.UIMapLastCenterCoordinate.latitude")
            self.permanentStore.set(self.UIMapLastCenterCoordinate.longitude,
                                    forKey: "TaRest.UIMapLastCenterCoordinate.longitude")
            //print("UIMapLastCenterCoordinate: \(self.UIMapLastCenterCoordinate)")
        }) }
    }
    
    public var UIMapLastSpan: MKCoordinateSpan =
    MKCoordinateSpan(latitudeDelta: 1.0,
                     longitudeDelta: 1.0) {
        
        didSet { self.DataQueue.async(flags: .barrier, execute: {
            self.permanentStore.set(self.UIMapLastSpan.latitudeDelta,
                                    forKey: "TaRest.UIMapLastSpan.latitudeDelta")
            self.permanentStore.set(self.UIMapLastSpan.longitudeDelta,
                                    forKey: "TaRest.UIMapLastSpan.longitudeDelta")
            //print("UIMapLastSpan: \(self.UIMapLastSpan)")

        }) }
    }
    
    // the content of the map (satelite etc.)
    public var MapContentMark: Int = 0 {
        
        didSet { self.DataQueue.async(flags: .barrier, execute: {
            self.permanentStore.set(self.MapContentMark,
                                    forKey: "TaRest.MapContentMark")
        }) }
    }

    
    // ---------------------------------------------------------------------------------------------
    // MARK: - API
    // ---------------------------------------------------------------------------------------------
    /**
     -----------------------------------------------------------------------------------------------
     
     reads the permananently stored values into the global storage. Values are stored in user defaults
     
     -----------------------------------------------------------------------------------------------
     */
    public func restoreGlobalData() {
        
        self.DataQueue.async(flags: .barrier, execute: {
            
            // the selected tab on MainTabBarController()
            self.UIMainTabBarSelectedTab = self.permanentStore.integer(
                forKey: "TaRest.UIMainTabBarSelectedTab")
           
            
            // This is the current sort strategy of ListTableViewController()
            self.UIListTableViewSortStrategy = self.permanentStore.integer(
                forKey: "TaRest.UIListTableViewSortStrategy")
           
            
            // restore the map region
            let mapCenterLatitude = self.permanentStore.double(
                forKey: "TaRest.UIMapLastCenterCoordinate.latitude")
            
            // a value "0.0" indicates that the value was not read, so we check all vaules
            // before we finally set center and span
            if mapCenterLatitude != 0.0 {
                
                let mapCenterLongitude = self.permanentStore.double(
                    forKey: "TaRest.UIMapLastCenterCoordinate.longitude")
                
                if mapCenterLongitude != 0.0 {
                    
                    let mapSpanLatitude = self.permanentStore.double(
                        forKey: "TaRest.UIMapLastSpan.latitudeDelta")
                    
                    if mapSpanLatitude != 0 {
                        
                        let mapSpanLongitude = self.permanentStore.double(
                            forKey: "TaRest.UIMapLastSpan.longitudeDelta")
                        
                        if mapSpanLongitude != 0 {
                            
                            self.UIMapLastCenterCoordinate = CLLocationCoordinate2D(
                                latitude: mapCenterLatitude,
                                longitude: mapCenterLongitude)
                            
                            self.UIMapLastSpan = MKCoordinateSpan(
                                latitudeDelta: mapSpanLatitude,
                                longitudeDelta: mapSpanLongitude)
                        }
                    }
                }
            }
            
            
            // content of the map (satelite etc.)
            self.MapContentMark = self.permanentStore.integer(
                forKey: "TaRest.MapContentMark")

            
            // the load of some UI elements is faster than this restore, so we send a post to sync it
            DispatchQueue.main.async(execute: {
                
                NotificationCenter.default.post(Notification(name: .TaRest_GlobalDataRestored))
                 
                ErrorList.unique.add("GlobalData.restoreGlobalData()", .info,"restoreGlobalData just posted .TaRest_GlobalDataRestored")
            })
        })
    }
    
}
