//
//  RestaurantData.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 13.05.21.
//

import Foundation
import UIKit
import CoreLocation

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
        
        let open: Double       // as seconds since midnight
        let close: Double
        
        init(_ open: Double, _ close: Double) {
            
            self.open = open
            self.close = close
        }
    }
    
    // Structure for the restaurant data
    struct DataStruct: Encodable, Decodable {
        let name: String
        var thumbImageName: String = "No Image 64"
        var fullSizeImageName: String = "No Image 128"
        let flags: String
        let coordinateLatitude: Double
        let coordinateLongitude: Double
        let hoursPerDay: [[timeSlotStruct]] // all days per week, several timeSlots per day
        
        init (_ name: String,
              _ thumbImageName: String,
              _ fullSizeImageName: String,
              _ flags: String,
              _ coordinateLatitude: Double,
              _ coordinateLongitude: Double,
              _ hoursPerDay: [[timeSlotStruct]]) {
            
            self.name = name
            self.flags = flags
            self.hoursPerDay = hoursPerDay
            
            if thumbImageName != "" {
                self.thumbImageName = thumbImageName
            }
            
            if fullSizeImageName != "" {
                self.fullSizeImageName = fullSizeImageName
            }
            
            self.coordinateLatitude = coordinateLatitude
            self.coordinateLongitude = coordinateLongitude
        }
    }
    
    // and the array of the restaurant data
    var DataArray: [DataStruct] = []
    
    // find the test data at the end of this class
    
    
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
    
    // for the DetailViewController this class provides preformatted data in this struct
    struct dataForDetailStruct {
        
        let name: String
        let image: UIImage
        let isOpen: String
        let flags: String
        let coordinate: CLLocationCoordinate2D
        
        init (_ name: String,
              _ image: UIImage,
              _ isOpen: String,
              _ flags: String,
              _ coordinate: CLLocationCoordinate2D) {
            
            self.name = name
            self.image = image
            self.isOpen = isOpen
            self.flags = flags
            self.coordinate = coordinate
        }
    }

    // ---------------------------------------------------------------------------------------------
    
    // we have two dictonaries for the images. Both dictonaries are prefilled with the "no image" image
    var thumbImageDic: [String : UIImage] = ["No Image 64" : UIImage(named: "No Image 64")!]
    var fullSizeImageDic: [String : UIImage] = ["No Image 128" : UIImage(named: "No Image 128")!]
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - ClassName API
    // ---------------------------------------------------------------------------------------------
    
    
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
        // we do it in three steps:
        // 1. Step (after 3 sec): we load testData 0
        // 2. Step (after addional 10 sec): we load testData 1
        // 3. Steps (after addional 10 sec): we load testData 2
        //
        // after each step we push the notification .TaRest_NewRestaurantDataAvailable
        
        GlobalData.unique.DataQueue.asyncAfter(deadline: .now() + .seconds(10), flags: .barrier, execute: {
            
            self.DataArray = self.testData_0

            ErrorList.unique.add("RestaurantData.startRestaurantData()", .info,
                                 "test 0, just replaced DataArray[] by testData_0[]")

            DispatchQueue.main.async(execute: {
                
                NotificationCenter.default.post(Notification(name: .TaRest_NewRestaurantDataAvailable))
                
                ErrorList.unique.add("RestaurantData.startRestaurantData()", .info,
                                     "restoreGlobalData just posted .TaRest_NewRestaurantDataAvailable")
                
            })


            
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
        })
    }
    
    
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
                let isOpenToUse = getOpenCloseString(restaurantIndex: index)
                
                // append what we have
                myData.append(dataForListStruct(index, item.name, imageToUse, isOpenToUse, item.flags, 0.0))
                
            } // loop
            
            // return the data
            return myData
        })
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     Provides the data of the restaurants needed for the ListTableViewController as [dataForListStruct].
     
     returns nil, if self.DataArray[] is empty
     
     -----------------------------------------------------------------------------------------------
     */
    public func getDataForDetail(_ index: Int) -> dataForDetailStruct {
        
        // to avoid data races we do it in the data queue
        GlobalData.unique.DataQueue.sync(execute: {
            
            // first check if we have data available
            if self.DataArray.isEmpty == true {
                
                // yes, data array is empty, so return "no data available"
                return dataForDetailStruct("no Data available",
                                           UIImage(named: "No Image 128")!,
                                           "",
                                           "",
                                           GlobalData.unique.UIMapLastCenterCoordinate)
            }
            
            // now check if the index is valid
            if (index < 0) || (index >= self.DataArray.count) {
                
                // yes, index is out of range, so return "no data available"
                return dataForDetailStruct("no Data available",
                                           UIImage(named: "No Image 128")!,
                                           "",
                                           "",
                                           GlobalData.unique.UIMapLastCenterCoordinate)
            }
            
            
            // if we reach here, we have valid data
            
             // shortcut to the data item
            let item = self.DataArray[index]
            
            // get the image
            let imageToUse: UIImage
            if let canditate = self.fullSizeImageDic[item.fullSizeImageName] {
                imageToUse = canditate
            } else {
                imageToUse = UIImage(named: "No Image 128")!
            }
            
            // get the string for the open status
            let isOpenToUse = getOpenCloseString(restaurantIndex: index)
            
            // get the coordinate of the restaurant
            let coordinateToUse = CLLocationCoordinate2D(
                latitude: item.coordinateLatitude, longitude: item.coordinateLongitude)
            
            // return what we have
            return dataForDetailStruct(item.name,
                                       imageToUse,
                                       isOpenToUse,
                                       item.flags,
                                       coordinateToUse)
        })
    }
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Internal Methodes
    // ---------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     returns the Int for the day of the week (Sunday == 0, Monday == 1, etc.)
     
     -----------------------------------------------------------------------------------------------
     */
    private func getNumberOfDayFromNow() -> Int {
        
        // we use the current calender
        let calendar = Calendar.current
        
        // we want the seconds from midnight until now
        let now = Date()
        
        // calculate the weekday as an integer (Sunday == 0, Monday == 1 etc.)
        let index = (calendar.component(.weekday, from: now) - 1)
        
        return index
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     returns the seconds (Double) between midnight and now
     
     -----------------------------------------------------------------------------------------------
     */
    private func getSecondsSinceMidnight() -> Double {
        
        // we use the current calender
        let calendar = Calendar.current
        
        // we want the seconds from midnight until now
        let now = Date()
        
        // get the components (debug friendly ;-) )
        let hours = calendar.component(.hour, from: now)
        let minutes = calendar.component(.minute, from: now)
        let seconds = calendar.component(.second, from: now)
        
        // calculate the return value
        let secondsInt = (hours * 60 * 60) + (minutes * 60) + seconds
        let secondsDouble = Double(secondsInt)
        
        //return what we have
        return secondsDouble
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     Returns a suitable string for the open / close phrase to use on View, like "open", "closes soon" etc.
     
     Have to be called inside a GlobalData.unique.DataQueue() closure
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
        - restaurantIndex: the index of the restaurant in self.DataArray[]
        - weekday: the number of the day in the week (Sunday == 0, Mondays == 1 etc.)
     
     - Returns: a string with a suitable phrase
     
     */
    private func getOpenCloseString(restaurantIndex: Int) -> String {
        
        // shortcur for the restaurant
        let restaurant = self.DataArray[restaurantIndex]
        
        // check if the restaurant has opening hours
        if restaurant.hoursPerDay.isEmpty == true {
            
            ErrorList.unique.add("RestaurantData.getOpenCloseString()", .info,
                                 "Restaurant \"\(restaurant.name)\" has no opening hours, return \"unknown\"")
            
            return NSLocalizedString("OpenCloseString-unknown", comment: "opening hours are unknown")
        }
        
        // get the weekday
        let weekday = getNumberOfDayFromNow()

        // check if weekday is a valid index
        if (weekday < 0) || (weekday >= restaurant.hoursPerDay.count) {
            
            // no, not a valid index, return
            ErrorList.unique.add("RestaurantData.getOpenCloseString()", .info,
                                 "Weekday (\(weekday)) is not a valid index (restaurant.hoursPerDay.count: \(restaurant.hoursPerDay.count)), return \"unknown\"")
            
            return NSLocalizedString("OpenCloseString-unknown", comment: "opening hours are unknown")
        }
        
        // shortcut for the opening hours from the weekday
        let weekdayItem = restaurant.hoursPerDay[weekday]
        
        // check if we have opening hours for that day
        if weekdayItem.isEmpty == true {
            
            // no, no hours at all, return unknown
            ErrorList.unique.add("RestaurantData.getOpenCloseString()", .info,
                                 "Restaurant \"\(restaurant.name)\" opening hours for weekday \(weekday) is empty, return \"unknown\"")
            
            return NSLocalizedString("OpenCloseString-unknown", comment: "opening hours are unknown")
        }
        
        // check if the restaurant is closed today
        if weekdayItem.first!.open == -1.0 {
            
            // yes, it is closed today
            return NSLocalizedString("OpenCloseString-closed today", comment: "opening hours are unknown")
        }
        
        
        // get he current time stamp
        let secondsNow = getSecondsSinceMidnight()
        
        // loop over the opening hours and look for the most suitable phrase
        for index in 0 ..< weekdayItem.count {
            
            let open = weekdayItem[index].open
            let openSoon = open - (30 * 60) // 30 minutes earlier
            
            let close = weekdayItem[index].close
            let closesSoon = close - (30 * 60) // 30 minures earlier
            
            if secondsNow < openSoon {
                return NSLocalizedString("OpenCloseString-closed", comment: "restaurant is closed")
                
            } else if secondsNow < open {
                return NSLocalizedString("OpenCloseString-opens soon", comment: "opening will open soon")
                
            } else if secondsNow < closesSoon {
                return NSLocalizedString("OpenCloseString-open", comment: "restaurant is open")
                
            } else if secondsNow < close {
                return NSLocalizedString("OpenCloseString-closes soon", comment: "restaurant will close soon")
            }
            
            // check if this is the last loop
            if index == (weekdayItem.count - 1) {
                
                // last loop, so we are behind the last close time, return closed
                return NSLocalizedString("OpenCloseString-closed", comment: "restaurant is closed")
            }
        } // loop
        
        // if we reached here, something does not work, report and return "unknown"
        ErrorList.unique.add("RestaurantData.getOpenCloseString()", .info,
                             "Restaurant \"\(restaurant.name)\" did not find suitable phrase for weekday \(weekday), return \"unknown\"")
        
        return NSLocalizedString("OpenCloseString-unknown", comment: "opening hours are unknown")
    }
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Test Data
    // ---------------------------------------------------------------------------------------------
    
    let testData_0: [DataStruct] = [
        DataStruct("restaurant 1", "", "", "🇨🇳🇹🇭🇮🇹🇩🇪🇺🇸",
                   52.520008, 13.404954,
                   [ // closed all day
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                   ]),
        DataStruct("restaurant 2", "", "", "🇨🇳🇹🇭🇮🇹🇩🇪",
                   52.520008, 13.404954,
                   [ // just one slot of open / close times
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                   ]),
        DataStruct("restaurant 3", "", "", "🇨🇳🇹🇭🇮🇹",
                   52.520008, 13.404954,
                   [ // two slots
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                  ]),
        DataStruct("restaurant 4 aa", "", "", "🇨🇳🇹🇭",
                   52.520008, 13.404954,
                   [ // three slots
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(13.0 * 3_600, 14.0 * 3_600),
                     timeSlotStruct(15.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(13.0 * 3_600, 14.0 * 3_600),
                     timeSlotStruct(15.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(13.0 * 3_600, 14.0 * 3_600),
                     timeSlotStruct(15.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(13.0 * 3_600, 14.0 * 3_600),
                     timeSlotStruct(15.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(13.0 * 3_600, 14.0 * 3_600),
                     timeSlotStruct(15.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(13.0 * 3_600, 14.0 * 3_600),
                     timeSlotStruct(15.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(13.0 * 3_600, 14.0 * 3_600),
                     timeSlotStruct(15.0 * 3_600, 19.0 * 3_600)],

                ]),
        DataStruct("restaurant 5 aa", "", "", "🇨🇳",
                   52.520008, 13.404954,
                   [ // no slots at all
                    
                ]),
        
        DataStruct("restaurant 6", "", "", "🇨🇳",
                   52.520008, 13.404954,
                   [ // just one slot
                        [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                   ]),
        
        DataStruct("restaurant 7 aa", "", "", "🇨🇳",
                   52.520008, 13.404954,
                   [ // all slots empty
                    [], [], [], [], [], [], [],
                   ]),
    ]
    
    let testData_1: [DataStruct] = [
        DataStruct("restaurant 1", "", "", "🇨🇳🇹🇭🇮🇹🇩🇪🇺🇸",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                   ]),
        DataStruct("restaurant 2aa", "", "", "🇨🇳🇹🇭🇮🇹🇩🇪",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],

                   ]),
        DataStruct("restaurant 3aa", "", "", "🇨🇳🇹🇭🇮🇹",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                  ]),
        DataStruct("restaurant 4", "", "", "🇨🇳🇹🇭",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
        DataStruct("restaurant 5aa", "", "", "🇨🇳",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
    ]
    
    let testData_2: [DataStruct] = [
        DataStruct("Asia kitchen", "", "", "🇨🇳🇹🇭",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(8.0 * 3_600, 16.0 * 3_600)],
                    [timeSlotStruct(8.0 * 3_600, 16.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 18.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(13.0 * 3_600, 15.0 * 3_600)],
                    [timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                   ]),
        DataStruct("Guilin Noodle Express aa", "", "", "🇨🇳",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(13.6 * 3_600, 15.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],

                   ]),
        DataStruct("Bella Italia", "", "", "🇮🇹",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 14.5 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                  ]),
        
        DataStruct("La Dolce Vita", "", "", "🇮🇹",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.75 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                  ]),
        DataStruct("Chiang Mai aa", "", "", "🇹🇭",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
        DataStruct("Bangkok Hilton", "", "", "🇹🇭",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
        DataStruct("Burger World aa", "", "", "🇺🇸",
                   52.520008, 13.404954,
                   [
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(-1.0, -1.0)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600),
                     timeSlotStruct(14.0 * 3_600, 19.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                    [timeSlotStruct(10.0 * 3_600, 12.0 * 3_600)],
                ]),
    ]

}
