import UIKit

var greeting = "Hello, playground"



let secondsSinceMidnightOpen: Double = 11.5 * 3_600.0

let secondsSinceMidnightClose: Double = 15.5 * 3_600.0

// example of openingsHours as an array of strings
let openHours: [String] = [
    "closed",
    "7:00 - 9:00",
    "17:00 - 19:00",
    "10:00 - 13:00 and   15:30 - 19:00 and 20:30 - 21:00",
    "10:00:00.5678 - 13:00",
    "closed",
    "10 - 13",
    "- 13",
    "10 and 13",
    "and",
    " ",
    "-"
    
]



// just a struct to seperate the strings
struct timeSlotStruct: Encodable, Decodable{
    
    let open: Double       // as seconds since midnight
    let close: Double
    
    init(_ open: Double, _ close: Double) {
        
        self.open = open
        self.close = close
    }
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

/**
 -----------------------------------------------------------------------------------------------
 
 converts an array with string of open hours of a week (per day like "12:00 - 13:00" or "12:00 - 13:00 and 14:00 - 15:30" or "closed" into an array of timeSlotsStructs per day
 
 -----------------------------------------------------------------------------------------------
 
 - Parameters:
    - openHours: a string array with the
 
 - Returns: per day an array of timeSlotStruct
 
 */
func convertOpenHoursStringArray(_ openHours: [String]) -> [[timeSlotStruct]] {
    
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
    var timeSlotArray : [[timeSlotStruct]] = []
    
    // outerloop over the array
    for outerLoopItem in seperatedStrings {
        
        // each day has it's own array of timeSlots
        var newDay: [timeSlotStruct] = []
        
        // this holds the openString until we found the suitable close string
        var openString: String = ""
        
        // by this we decide if the next time element will be the open time or the close time
        var nextWillBeOpen: Bool = true
        
        // loop over all elements of this day
        for innerLoopItem in outerLoopItem {
            
            // we parse be a switch staement
            switch innerLoopItem {
            
            case "closed":  // all day closed
                newDay.append(timeSlotStruct(-1.0, -1.0))
                nextWillBeOpen = true
                
            case "and":     // there are several timeslots for that day
                nextWillBeOpen = true
                
            case "-":       // separation between open and close times
                nextWillBeOpen = false
                
                
            default:        // this will be the times
                
                // chcek if this should be an open time
                if nextWillBeOpen == true {
                    
                    // yes, it is an open time, so store it for later use
                    openString = innerLoopItem
                    
                } else {
                    
                    // no, so we found the close time and can now build the timeSlot
                    
                    //print ("openString: \(openString), innerLoopItem: \(innerLoopItem)")
                    
                    // convert the strings into seconds since midnight
                    let secondsOpen = convertStringIntoSecondsSinceMidnight(openString)
                    let secondsClose = convertStringIntoSecondsSinceMidnight(innerLoopItem)
                    
                    //print ("secondsOpen: \(secondsOpen), secondsClose: \(secondsClose)")
                    
                    // build the timeslot and append it
                    newDay.append(timeSlotStruct(secondsOpen, secondsClose))
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


let myTimeFormatter = DateComponentsFormatter()
myTimeFormatter.unitsStyle = .positional
myTimeFormatter.allowedUnits = [.hour, .minute]
myTimeFormatter.zeroFormattingBehavior = [.pad]

let DoubleArray = convertOpenHoursStringArray(openHours)

print("------------------------------------------")

for dayItem in DoubleArray {
    
    print("new day")
    
    for hourItem in dayItem {
        
        if hourItem.open == -1.0 {
            print ("closed")
        } else {
            
            let open = myTimeFormatter.string(from: hourItem.open) ?? "not working"
            let close = myTimeFormatter.string(from: hourItem.close) ?? "not working"
            
            print("\(open) - \(close)")
        }
    }
}

print("------------------------------------------")


