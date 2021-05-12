//
//  ErrorList.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 12.05.21.
//

import Foundation


// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Error List
//
// Preconditions:
// - "GlobalDataQueue" is used to synchronise the data access and must be available. It is used with the flag ".concurrent" on write operations
// -------------------------------------------------------------------------------------------------
final class ErrorList: NSObject {
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Singleton
    // ---------------------------------------------------------------------------------------------
    static let unique = ErrorList()
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------------------------
    // we use thius string to name the class in logs
    private let shortNameLog: String = "ErrorList"
    
    // filename to use to store the error messages
    private let myDefaultsFileName: String = "ErrorList"
        
    // name of the notification to send, if new error stored
    private let myNotificationNeme: Notification.Name = .TaRest_NewErrorListed
    
    // max number of errors (error 51 will remove error 1)
    private let maxNumberOfErrorsStored: Int = 50
    
    // we use this formatter for the timesStrings in getCurrentErrors().
    // the formatter will get his setup in establishErrorList()
    private let myTimeStringFormatter = DateFormatter()
    
    

    // ---------------------------------------------------------------------------------------------
    // MARK: - ErrorList API
    // ---------------------------------------------------------------------------------------------
    /**
     -----------------------------------------------------------------------------------------------
     
     Initializes the ErrorList enviroment
     
     -----------------------------------------------------------------------------------------------
     */
    public func establishErrorList() {
        
        // setup of the formatter
        myTimeStringFormatter.dateStyle = .medium
        myTimeStringFormatter.timeStyle = .medium
        myTimeStringFormatter.doesRelativeDateFormatting = true
        
        // we willchack nd ensure that the application support directory is dreally available
        
        // Instance of a private filemanager
        let myFileManager = FileManager.default

        // get the application support directory URL
        if let applicationSupportDirectoryURL = myFileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            
            // convert it to a path
            let applicationSupportDirectoryPath:String = applicationSupportDirectoryURL.path
            
            // check if we have to create the directory
            if myFileManager.fileExists(atPath: applicationSupportDirectoryPath) == false {
                
                // does not exist, so create it
                do {
                    try myFileManager.createDirectory(atPath: applicationSupportDirectoryPath,
                                                      withIntermediateDirectories: false,
                                                      attributes: nil)
                    
                    
                    // report what we did, nothing to read there, as we just created the directory
                    self.add("ErrorList.establishErrorList()", .info, "just created .applicationSupportDirectory (\"\(applicationSupportDirectoryPath)\")")
                    
                } catch let error  {
                    
                    self.add("ErrorList.establishErrorList()", .error, "creation of .applicationSupportDirectory directory failed, error: \"\(error)\", did not read myDefaults")
                    
                    return
                }
                
            } else {
                
                // all OK
                // we just have to restore the old values
                self.readMyDefaults()
                
                self.add("ErrorList.establishErrorList()", .info, ".applicationSupportDirectory exists, already read stored error messages")
            }

        } else {
            
            // no app support directory
            self.add("ErrorList.establishErrorList()", .error, "did not get a valid diretory for \".applicationSupportDirectory\", did not read myDefaults")
        }
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     Logs the error text as NSLog() and stores it in an internal ring buffer (self.lastErros[]), size: maxNumberOfErrorsStored
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
     
        - errorType: type of the error (Info, error etc.)
        - errorText: Text of the error to log and store
     
     - Returns: nothing
     
     */
    public func add(_ from: String, _ errorType: errorTypeEnum, _ errorText: String) {
        
        // check if we list this error in this enviroment
        if self.allowedErrorTypes.contains(errorType) {
            
            // log it on console
            NSLog("\(from): \(errorType.rawValue) - \(errorText)")
            
            GlobalData.unique.DataQueue.async(flags: .barrier, execute: {
                
                
                // check if the buffer is full
                while self.lastErrors.count >= self.maxNumberOfErrorsStored {
                    
                    // yes buffer is full, so remove the oldest
                    self.lastErrors.removeFirst()
                }
                
                // append the new error and list it as an NSLog as well
                self.lastErrors.append(lastErrorStruct(from, errorType, errorText))
                
                // save the values
                self.writeMyDefaults()
                
                // local notification to update UI
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(Notification(name: self.myNotificationNeme))
                })
            })
        }
    }
    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     returns the current erros in two related arrays. dates[] holds the formatted string of the timeStamp and strings[] holds the formatted error text
     
     -----------------------------------------------------------------------------------------------
     */
    public func getCurrentErrors() -> (dates: [String], strings: [String]) {
        
        // first step: get the current errors
        let myErrors = GlobalData.unique.DataQueue.sync(execute: {
            return self.lastErrors
        })
        
        // second step: sort them to be sure they are in the right sequence (newest first)
        let sortedErrors = myErrors.sorted(by: { $0.errorTimeStamp > $1.errorTimeStamp } )
        
        // third step: format the errors and put them into the array
        
        // container for the return values
        var myDates: [String] = []
        var myStrings: [String] = []
        
        for item in sortedErrors {
            
            // format the timeStamp into a nice and readable format
            let myDate: Date = Date(timeIntervalSinceReferenceDate: item.errorTimeStamp)
            let timeStampString: String = myTimeStringFormatter.string(from: myDate)
            myDates.append(timeStampString)
            
            // add the error string
            myStrings.append("\(item.from): \(item.errorType) - \(item.errorText)")
        }
        
        return (myDates, myStrings)
        
    }
    
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - List Errors Storage
    // ---------------------------------------------------------------------------------------------

    // errors could be classified
    public enum errorTypeEnum : String {
        case info = "Info", error = "Error"
    }
    
    // in production environment we only report errors, in debug we also report infos
    // we use this array to filter the messages
    #if DEBUG
    let allowedErrorTypes: [errorTypeEnum] = [.info, .error]
    #else
    let allowedErrorTypes: [errorTypeEnum] = [.error]
    #endif

    // we use this struct to
    public struct lastErrorStruct: Decodable, Encodable {
        
        let errorTimeStamp: TimeInterval
        let from: String
        let errorType: String
        let errorText: String
        
        init(_ from: String, _ errorType: errorTypeEnum, _ errorText: String) {
            
            self.from = from
            self.errorType = errorType.rawValue
            self.errorText = errorText
            self.errorTimeStamp = CFAbsoluteTimeGetCurrent()
        }
    }
    
    // this is the array with the last errors
    public var lastErrors: [lastErrorStruct] = []


    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Internal Methodes
    // ---------------------------------------------------------------------------------------------
    
    
    // --------------------------------------------------------------------
    // MARK: - myDefaults core methodes
    //
    // this core methodes have the same code in several classes.
    // The reason we did not put this into a seperated class is, that a struct, which is the container
    // of the variables, can't be inheritated .. and a class is hard to decode / encode
    // so we stuck with this code doubled ....
    // To avoid endless loops, the error messages from this methodes are done by standard NSLogs()
    // --------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     Properties
     
     -----------------------------------------------------------------------------------------------
     */
    // just a flag that we do no read the values again and again
    private var readMyDefaultsDone: Bool = false

    
    /**
     -----------------------------------------------------------------------------------------------
     
     readMyDefaults()
     
     -----------------------------------------------------------------------------------------------
     */
    private func readMyDefaults() {
        
        // sync the work
        GlobalData.unique.DataQueue.sync(flags: .barrier, execute: {
            
            // check if we already did it
            if readMyDefaultsDone == false {
                
                // prepare file handling
                let pListFileName = self.myDefaultsFileName
                let myFilemanager = FileManager.default
                
                // try to get the directory
                if let rootFileURL = myFilemanager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                    
                    // try to get the URL of pList file
                    if let fileForPListURL = URL(string: pListFileName, relativeTo: rootFileURL) {
                        
                        // build the file path
                        let pListFilePath = fileForPListURL.path
                        
                        // try to read the data of the file
                        if let dataJustRead = myFilemanager.contents(atPath: pListFilePath) {
                            
                            // prepare decoder
                            let decoder = JSONDecoder()
                            do {
                                
                                // try to decode the content of the file
                                self.lastErrors = try decoder.decode([ErrorList.lastErrorStruct].self, from: dataJustRead)
                                
                                // everythings works fine, so flag success
                                self.readMyDefaultsDone = true
                                
                            } catch {
                                
                                NSLog("\(self.shortNameLog).readMyDefaults(): ERROR: decode of pList data failed, Error: \(error)")
                            }
                            
                        } else {
                            
                            NSLog("\(self.shortNameLog).readMyDefaults(): ERROR: could not read content of pList File, use the app defaults")
                        }
                        
                    } else {
                        
                        NSLog("\(self.shortNameLog).readMyDefaults(): ERROR: failed to get the URL of pList file")
                    }
                    
                } else {
                    
                    NSLog("\(self.shortNameLog).readMyDefaults(): ERROR: failed to get the directory (applicationSupportDirectory) for pList file")
                }
            } else {
                
            }
        })
    }
    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     writeWIS_Defaults()
     
     Have to be called inside a GlobalData.unique.DataQueue call
     
     -----------------------------------------------------------------------------------------------
     */
    private func writeMyDefaults() {
        
        // prepare the file Handling
        let pListFileName = myDefaultsFileName
        let myFilemanager = FileManager.default
        
        // try to get the directory
        if let rootFileURL = myFilemanager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            
            // try to get the URL
            if let fileForPListURL = URL(string: pListFileName, relativeTo: rootFileURL) {
                
                // build the file path
                let pListFilePath = fileForPListURL.path
                
                // get the encoder
                let encoder = JSONEncoder()
                
                do {
                    // try to get the data from the WIS_Defaults
                    let dataToWrite = try encoder.encode(self.lastErrors)
                    
                    // create new file (even if old one exist) with the content of the data object
                    myFilemanager.createFile(atPath: pListFilePath, contents: dataToWrite, attributes: nil)
                    
                    #if DEBUG
                    NSLog("\(self.shortNameLog).writeMyDefaults(): just wrote WIS_Defaults to file")
                    #endif
                                        
                } catch {
                    
                    NSLog("\(self.shortNameLog).writeMyDefaults(): ERROR: encode of pList data failed, Error: \(error.localizedDescription)")
                }
                
            } else {
                
                NSLog("\(self.shortNameLog).writeMyDefaults(): ERROR: failed to get the URL of pList file")
            }
            
        } else {
            
            NSLog("\(self.shortNameLog).writeMyDefaults(): ERROR: failed to get the directory (applicationSupportDirectory) of pList file")
        }
    }

    
}
