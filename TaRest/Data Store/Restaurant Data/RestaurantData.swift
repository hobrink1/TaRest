//
//  RestaurantData.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 13.05.21.
//

import Foundation
import UIKit

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Restaurant Data
// -------------------------------------------------------------------------------------------------
final class RestaurantData: NSObject {
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Singleton
    // ---------------------------------------------------------------------------------------------
    static let unique = RestaurantData()
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------------------------
    
    // each restaurant can have multiple timeslots, so we need a struct for a better model
    struct timeSlotStruct: Encodable, Decodable{
        
        let start: Double       // as seconds since midnight
        let end: Double
        
        init(_ start: Double, _ end: Double) {
            
            self.start = start
            self.end = end
        }
    }
    
    // Structure for the restaurant data
    struct DataStruct: Encodable, Decodable {
        let name: String
        var thumbImageName: String = "No Image 64"
        let flags: String
        let hoursPerDay: [[timeSlotStruct]] // all days per week, several timeSlots per day
        
        init (_ name: String,
              _ thumbImageName: String,
              _ flags: String,
              _ hoursPerDay: [[timeSlotStruct]]) {
            
            self.name = name
            self.flags = flags
            self.hoursPerDay = hoursPerDay
            
            if thumbImageName != "" {
                self.thumbImageName = thumbImageName
            }
        }
    }
    
    // and the array of the restaurant data
    var DataArray: [DataStruct] = []
    
    let testData_1: [DataStruct] = [
        DataStruct("restaurant 1", "", "🇨🇳🇹🇭🇮🇹🇩🇪🇺🇸",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                   ]),
        DataStruct("restaurant 2", "", "🇨🇳🇹🇭🇮🇹🇩🇪",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],

                   ]),
        DataStruct("restaurant 3", "", "🇨🇳🇹🇭🇮🇹",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                  ]),
        DataStruct("restaurant 4", "", "🇨🇳🇹🇭",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
        DataStruct("restaurant 5", "", "🇨🇳",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
    ]
    
    let testData_2: [DataStruct] = [
        DataStruct("Asia kitchen", "", "🇨🇳🇹🇭",
                   [
                    [timeSlotStruct(8.0 * 3_600, 16.0 * 3_600)],
                    [timeSlotStruct(8.0 * 3_600, 16.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 18.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(13.0 * 3_600, 15.0 * 3_600)],
                    [timeSlotStruct(11.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                   ]),
        DataStruct("Guilin Noodle Express", "", "🇨🇳",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],

                   ]),
        DataStruct("Bella Italia", "", "🇮🇹",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                  ]),
        DataStruct("La Dolce Vita", "", "🇮🇹",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                  ]),
        DataStruct("Chiang Mai", "", "🇹🇭",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
        DataStruct("Bangkok Hilton", "", "🇹🇭",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
        DataStruct("Burger World", "", "🇺🇸",
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(-1.0 * 3_600, -1.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)], [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
    ]
    
    // ---------------------------------------------------------------------------------------------
    
    // for the ListTableView this class provides preformatted data in an array of this struct
    struct dataForListStruct : Hashable {
        
        let index: Int          // the index in DataArray[], DetailView use this index
        let name: String
        let image: UIImage
        let isOpen: String
        let flags: String
        var distance: Double
        
        init (_ index: Int,
              _ name: String,
              _ image: UIImage,
              _ isOpen: String,
              _ flags: String,
              _ distance: Double) {
            
            self.index = index
            self.name = name
            self.image = image
            self.isOpen = isOpen
            self.flags = flags
            self.distance = distance
        }
    }
    
    // ---------------------------------------------------------------------------------------------
    
    // we have two dictonaries for the images. Both dictonaries are prefilled with the "no image" image
    var thumbImageDic: [String : UIImage] = ["No Image 64" : UIImage(named: "No Image 64")!]
    var bigImageDic: [String : UIImage] = ["No Image 128" : UIImage(named: "No Image 128")!]
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - ClassName API
    // ---------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     Provides the data of the restaurants needed for the ListTableViewController as [dataForListStruct].
     
     returns nil, if self.DataArray[] is empty
     
     -----------------------------------------------------------------------------------------------
     */
    public func getDataForList() -> [dataForListStruct]? {
        
        // to avoid data races we do it in the data queue
        GlobalData.unique.DataQueue.sync(execute: {
            
            // first check if we have data available
            if self.DataArray.isEmpty == true {
                
                // yes, data array is empty, so return nil to indicate "no data available"
                return nil
            }
            
            // if we reach here, we have valid data
            
            // this is the container for the return data, created as an empty array
            var myData: [dataForListStruct] = []
            
            for index in 0 ..< self.DataArray.count {
                
                // shortcut to the data item
                let item = self.DataArray[index]
                
                // get the image
                let imageToUse: UIImage
                if let canditate = self.thumbImageDic[item.thumbImageName] {
                    imageToUse = canditate
                } else {
                    imageToUse = UIImage(named: "No Image 64")!
                }
                
                // get the string for the open status
                let isOpenToUse: String
                
                if item.hoursPerDay.isEmpty == true {
                    
                    isOpenToUse = "unknown"
                    
                } else {
                    
                    let dayOfWeek = self.getNumberOfDayFromNow() - 1
                    
                    // check if the index is valid
                    if (dayOfWeek < 0) || (dayOfWeek >= item.hoursPerDay.count) {
                        
                        isOpenToUse = "unknown"
                        
                    } else {
                        
                        // yes, we have a valid index, check if it is open
                        if item.hoursPerDay[dayOfWeek].first!.start == -1.0 {
                            
                            // it's closed whole day, report that
                            isOpenToUse = "closed"
                            
                        } else {
                            
                            // it has opening hours for today, so check if it is open now
                            isOpenToUse = "open"
                        }
                    }
                }
                // append what we have
                myData.append(dataForListStruct(index, item.name, imageToUse, isOpenToUse, item.flags, 0.0))
                
            } // loop
            
            // return the data
            return myData
        })
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
     - :
     
     - Returns:
     
     */
    public func startRestaurantData() {
        
        // this is the test sequence, to test the several view controllers.
        //
        // we do it in two steps:
        // 1. Step (after 10 sec): we load testData 1
        // 2. Steps (after addional 10 sec): we load testData 2
        //
        // after each step we push the notification .TaRest_NewRestaurantDataAvailable
        
        ErrorList.unique.add("RestaurantData.startRestaurantData()", .info,
                             "test mode, will replace data in 10 seconds")


        GlobalData.unique.DataQueue.asyncAfter(deadline: .now() + .seconds(10), flags: .barrier, execute: {
            self.DataArray = self.testData_1
 
            ErrorList.unique.add("RestaurantData.startRestaurantData()", .info,
                                 "test 1, just replaced DataArray[] by testData_1[]")

            DispatchQueue.main.async(execute: {
                
                NotificationCenter.default.post(Notification(name: .TaRest_NewRestaurantDataAvailable))
                 
                ErrorList.unique.add("RestaurantData.startRestaurantData()", .info,
                                     "restoreGlobalData just posted .TaRest_NewRestaurantDataAvailable")

            })
            
            GlobalData.unique.DataQueue.asyncAfter(deadline: .now() + .seconds(10), flags: .barrier, execute: {
                self.DataArray = self.testData_2
     
                ErrorList.unique.add("RestaurantData.startRestaurantData()", .info,
                                     "test 2, just replaced DataArray[] by testData_2[]")

                DispatchQueue.main.async(execute: {
                    
                    NotificationCenter.default.post(Notification(name: .TaRest_NewRestaurantDataAvailable))
                     
                    ErrorList.unique.add("RestaurantData.startRestaurantData()", .info,
                                         "restoreGlobalData just posted .TaRest_NewRestaurantDataAvailable")

                })
            })
        })
    }
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Internal Methodes
    // ---------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
     - :
     
     - Returns:
     
     */
    private func getNumberOfDayFromNow() -> Int {
        
        let index = Calendar.current.component(.weekday, from: Date())
        
        return index
    }
    
}
