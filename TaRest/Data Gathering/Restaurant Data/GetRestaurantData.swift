//
//  GetRestaurantData.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 12.05.21.
//

import Foundation


// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Get Restaurant Data
// -------------------------------------------------------------------------------------------------
final class GetRestaurantData: NSObject {
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Singleton
    // ---------------------------------------------------------------------------------------------
    static let unique = GetRestaurantData()
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------------------------
    let downloadURL: String = "https://restaurants-service-trial-day.herokuapp.com/restaurants"
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - GetRestaurantData API
    // ---------------------------------------------------------------------------------------------
    
    
    
    public func downloadRestaurantData() {
        
        // build a valid URL
        if let url = URL(string: self.downloadURL) {
            
            // build the task and define the completion handler
            let task = URLSession.shared.dataTask(
                with: url,
                completionHandler: { data, response, error in
                    
                    ErrorList.unique.add("GetRestaurantData.downloadRestaurantData()", .info,
                                         ".completionHandler just started")
                    
                    // check if there are errors
                    if error == nil {
                        
                        // no errors, go ahead
                        
                        // check if we have a valid HTTP response
                        if let httpResponse = response as? HTTPURLResponse {
                            
                            // check if we have a a good status (codes from 200 to 299 are always good
                            if (200...299).contains(httpResponse.statusCode) == true {
                                
                                // good status, go ahead
                                
                                // check if we have a mimeType
                                if let mimeType = httpResponse.mimeType {
                                    
                                    // check the mime type
                                    //if mimeType == "text/plain" {
                                    if mimeType == "application/json" {

                                        // right mime type, go ahead
                                        
                                        // check the data
                                        if data != nil {
                                            
                                            // we have data, go ahead
                                            
                                            // convert it to string and print it (used for testing AND
                                            // for quickType webside to generate the "JSON RKI ....swift" files
                                            print("\(String(data: data!, encoding: .utf8) ?? "Convertion data to string failed")")
                                            
                                            // handle the content
                                            self.handleNewContent(data!)
                                            
                                        } else {
                                            
                                            // no valid data, log message and return
                                            ErrorList.unique.add("GetRestaurantData.downloadRestaurantData()", .error, "data == nil, no valid data, return")
                                            return
                                        }
                                        
                                    } else {
                                        
                                        // not the right mimeType, log message and return
                                        ErrorList.unique.add("GetRestaurantData.downloadRestaurantData()", .error, "wrong mimeType (\"\(mimeType)\" instead of \"application/json\"), return")
                                        return
                                    }
                                    
                                } else {
                                    
                                    // no valid mimeType, log message and return
                                    ErrorList.unique.add("GetRestaurantData.downloadRestaurantData()", .error, "no mimeType in response, return")
                                    return
                                }
                                
                            } else {
                                
                                // not a good status, log message and return
                                ErrorList.unique.add("GetRestaurantData.downloadRestaurantData()", .error, "Server responded with error status: \(httpResponse.statusCode), return")
                                return
                            }
                            
                        } else {
                            
                            // no valid response, log message and return
                            ErrorList.unique.add("GetRestaurantData.downloadRestaurantData()", .error, "has no valid HTTP response, return")
                            return
                        }
                        
                    } else {
                        
                        // error is not nil, check if error code is valid
                        if let myError = error  {
                            
                            // valid errorCode, call the handler and return
                            ErrorList.unique.add("GetRestaurantData.downloadRestaurantData()", .error, " handleServerError(), \(myError.localizedDescription)")
                            return
                            
                        } else {
                            
                            // no valid error code, log message and return
                            ErrorList.unique.add("GetRestaurantData.downloadRestaurantData()", .error, "dataTask came back with error which is not nil, but no valid errorCode, return")
                            return
                        }
                    }
                })
            
            // start the task
            task.resume()
            
        } else {
            
            // no valid URL, log message and return
            ErrorList.unique.add("GetRestaurantData.downloadRestaurantData()", .error, "no valid URL, return")
            return
        }

    }
    
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Internal Methodes
    // ---------------------------------------------------------------------------------------------

    /**
    -----------------------------------------------------------------------------------------------
    
    Decodes the JSON data and stores it into global storage
    
    -----------------------------------------------------------------------------------------------
    
    - Parameters:
       - data: prepared JSON data
       - RKI_DataType: enum what kind of data is provided
    
    - Returns: nothing
    */

    private func handleNewContent( _ data: Data) {
        
        // report start
        ErrorList.unique.add("GetRestaurantData.handleNewContent()", .info, "handleNewContent just started")
        
        
        do {
             
            // try to decode the JSON data
            let newData = try newJSONDecoder().decode([TaRestElement].self, from: data)
            
            // just reporting, no errors occure
            ErrorList.unique.add("GetRestaurantData.handleNewContent()", .info, " after decoding")
            
            // check if the data is valid
            if newData.isEmpty == false {
                
                // this will hold all image URLs
                var NameAndImageURLDic: [String : String] = [:]
                   
                // we will provide an array of the new restaurants
                var newDataArray: [RestaurantData.DataStruct] = []
                
                // walk over data and build array
                for singleItem in newData {
                    
                    // first step: translate the kittchen type phrases into a single string of flags
                    var newFlags: String = ""
                    
                    // we translate the kittchen type by a loop with a switch statement
                    for singleKitchen in singleItem.kitchenTypes {
                        
                        switch singleKitchen {
                        
                        case "thai":
                            newFlags.append("🇹🇭")
                            
                        case "italian":
                            newFlags.append("🇮🇹")
                            
                        case "american":
                            newFlags.append("🇺🇸")
                            
                        case "german":
                            newFlags.append("🇩🇪")
                            
                        case "chinese":
                            newFlags.append("🇨🇳")
                            
                        default:
                            ErrorList.unique.add("GetRestaurantData.handleNewContent()", .error, "Unknown kittchenType \"\(singleKitchen)\"")
                        }
                    }
                    
                    
                    // second: Convert the array of strings into our internal data format
                    let newOpeningHours = self.convertOpenHoursStringArray(singleItem.openinghours)
                    
                    // third: the locations; we use our default coordinate (mid of Berlin) if not valid
                    let newLatitude = Double(singleItem.location.lat) ?? 52.453730238865944
                    let newLongitude = Double(singleItem.location.lon) ?? 13.445109940799426
                    
                    // fifth: build the new data set and append it
                    let newDataSet = RestaurantData.DataStruct(singleItem.name,
                                                               "", "",
                                                               newFlags,
                                                               newLatitude,
                                                               newLongitude,
                                                               newOpeningHours)
                    
                    newDataArray.append(newDataSet)
                    
                    // sixth: store the URL for the image
                    NameAndImageURLDic[singleItem.name] = singleItem.presentationImage
                    
                }
                
                // report the new data
                RestaurantData.unique.handleNewRestaurantData(newDataArray, NameAndImageURLDic)
                
                ErrorList.unique.add("GetRestaurantData.handleNewContent()", .info, "done")
                
            } else {
                
                ErrorList.unique.add("GetRestaurantData.handleNewContent()", .error, "data were empty, do nothing")
            }
             
        } catch let error as NSError {
            
            ErrorList.unique.add("GetRestaurantData.handleNewContent()", .error, "JSON decoder failed: error: \"\(error.description)\", return")
            return
        }
    }
    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     converts an array with string of open hours of a week (per day like "12:00 - 13:00" or "12:00 - 13:00 and 14:00 - 15:30" or "closed" into an array of timeSlotsStructs per day
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
        - openHours: a string array with the
     
     - Returns: per day an array of timeSlotStruct
     
     */
    func convertOpenHoursStringArray(_ openHours: [String]) -> [[RestaurantData.timeSlotStruct]] {
        
        // We do in tweo steps
        // first: seperate all string elements
        // second: parse this elements and build the timeSlotStructs
        
        
        // first: seperate all string elements
        
        // this will hold the separated strings after seperating
        var seperatedStrings : [[String]] = []
        
        // loop over the openin hours and splitt them into seperated elements
        for hourItems in openHours {
            
            // each string has at least two elements (open and close), so we need an array to hold this
            var newItem: [String] = []
            
            // split the current item into the seperated substrings
            let elements = hourItems.split(separator: Character(" "))
            
            // unfortunatly we have to convert each of the subStrings into a string
            for singleItem in elements {
                
                // convert it
                let newString = String(singleItem)
                
                // check if there is a valid string
                if newString.isEmpty == false {
                    
                    // append it to the newItem
                    newItem.append(newString)
                }
            }
            
            // check if we found something
            if newItem.isEmpty == false {
                // yes we found it, so append it
                seperatedStrings.append(newItem)
            }
        }
        
        
        // second: parse this elements and build the timeSlotStructs

        // this will hold the results
        var timeSlotArray : [[RestaurantData.timeSlotStruct]] = []
        
        // outerloop over the array
        for outerLoopItem in seperatedStrings {
            
            // each day has it's own array of timeSlots
            var newDay: [RestaurantData.timeSlotStruct] = []
            
            // this holds the openString until we found the suitable close string
            var openString: String = ""
            
            // by this we decide if the next time element will be the open time or the close time
            var nextWillBeOpen: Bool = true
            
            // loop over all elements of this day
            for innerLoopItem in outerLoopItem {
                
                // we parse be a switch staement
                switch innerLoopItem {
                
                case "closed", "Closed":  // all day closed
                    newDay.append(RestaurantData.timeSlotStruct(-1.0, -1.0))
                    nextWillBeOpen = true
                    
                case "and":     // there are several timeslots for that day
                    nextWillBeOpen = true
                    
                case "-":       // separation between open and close times
                    nextWillBeOpen = false
                    
                case "-19:00":  // misformatted data in JSON data, do a work around
                    // convert the strings into seconds since midnight
                    let secondsOpen = self.convertStringIntoSecondsSinceMidnight(openString)
                    let secondsClose = self.convertStringIntoSecondsSinceMidnight(String(innerLoopItem.dropFirst(1)))
                    
                    // build the timeslot and append it
                    newDay.append(RestaurantData.timeSlotStruct(secondsOpen, secondsClose))

                    // next item will be again an opening hour
                    nextWillBeOpen = true

                    
                default:        // this will be the times
                    
                    // chcek if this should be an open time
                    if nextWillBeOpen == true {
                        
                        // yes, it is an open time, so store it for later use
                        openString = innerLoopItem
                        
                    } else {
                        
                        // no, so we found the close time and can now build the timeSlot
                        
                        // convert the strings into seconds since midnight
                        let secondsOpen = self.convertStringIntoSecondsSinceMidnight(openString)
                        let secondsClose = self.convertStringIntoSecondsSinceMidnight(innerLoopItem)
                        
                        //print ("secondsOpen: \(secondsOpen), secondsClose: \(secondsClose)")
                        
                        // build the timeslot and append it
                        newDay.append(RestaurantData.timeSlotStruct(secondsOpen, secondsClose))
                        
                        // next item will be again an opening hour
                        nextWillBeOpen = true
                    }
                    
                }  // switch
            } // inner loop
            
            // check if we found something for that day
            if newDay.isEmpty == false {
                
                // yes we found something so append the day
                timeSlotArray.append(newDay)
            }
        } // outer loop
        
        // return what we found
        return timeSlotArray
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     converts a string like "12" (as 12 o'clock) or "12:00" or "12:00:30.5678" into seconds since midnight
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
        - myString: string to parse
     
     - Returns: seconds since midnight
     
     */
    func convertStringIntoSecondsSinceMidnight(_ myString:String) -> Double {
        
        var seconds: Double = 0
        let parts = myString.split(separator: Character(":"))
        
        for index in 0 ..< parts.count {
            let part = parts[index]
            seconds += (Double(part) ?? 0) * pow(Double(60), Double(2 - index))
        }
        
        //print("myString: \(myString) -> seconds: \(seconds)")
        return seconds
    }


}
    
