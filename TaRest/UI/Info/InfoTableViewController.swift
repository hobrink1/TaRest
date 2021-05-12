//
//  InfoTableViewController.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 12.05.21.
//

import UIKit


// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - InfoTableViewController
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Class
// -------------------------------------------------------------------------------------------------

final class InfoTableViewController: UITableViewController {
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------------------------
    
    // we use an internal table to config the apearance of the info
    // The dataType decides if the cell texts will be translated or not
    // .singleString and .doubleString will always translated
    // .errorMessage will never translated
    
    // this is the cell type
    private enum localDataEnum {
        case singleString, doubleString, errorMessage, version, locationService
    }
    
    // this is the struct we use to config the tableView
    private struct localDataStruct {
        let localDataType: localDataEnum
        let label1: String
        let label2: String
        
        init(dataType: localDataEnum, label1: String, label2: String) {
            self.localDataType = dataType
            self.label1 = label1
            self.label2 = label2
        }
    }
    
    // This is the config for the table view
    private let InfoTexts: [localDataStruct] = [
        
        localDataStruct(dataType: .version,
                        label1: "", label2: ""),
        
        localDataStruct(dataType: .locationService,
                        label1: "Location-Status", label2: ""),

        localDataStruct(dataType: .doubleString,
                        label1: "Info-Main-Header", label2: ""),
        
        localDataStruct(dataType: .doubleString,
                        label1: "Info-1-Header", label2: "Info-1"),
        
        localDataStruct(dataType: .doubleString,
                        label1: "Info-2-Header", label2: "Info-2"),
        
        localDataStruct(dataType: .doubleString,
                        label1: "", label2: ""),
        
        localDataStruct(dataType: .doubleString,
                        label1: "Data-Privacy-Header", label2: "Data-Privacy"),
        
        localDataStruct(dataType: .doubleString,
                        label1: "", label2: ""),
    ]
    
    private var localData: [localDataStruct] = []
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Helpers
    // ---------------------------------------------------------------------------------------------
    /**
     -----------------------------------------------------------------------------------------------
     
     refresh local data
     
     -----------------------------------------------------------------------------------------------
     */
    private func refreshLocalData() {
        
        var localDataBuild: [localDataStruct] = []
        
        for item in InfoTexts {
            
            switch item.localDataType {
            
            case .version:
                
                // just the version string
                // append a new record
                localDataBuild.append(localDataStruct(
                                        dataType: item.localDataType,
                                        label1: "",
                                        label2: "\(VersionLabel) © 2021 Hartwig Hopfenzitz"))
                
                
                
            case .singleString:
                
                // translate the label text
                let label1Text = NSLocalizedString(item.label1, comment: "")
                
                // append a new record
                localDataBuild.append(localDataStruct(
                                        dataType: item.localDataType,
                                        label1: label1Text,
                                        label2: ""))
                
                
            case .doubleString:
                
                // translate the label texts
                let label1Text = NSLocalizedString(item.label1, comment: "")
                let label2Text = NSLocalizedString(item.label2, comment: "")
                
                // append a new record
                localDataBuild.append(localDataStruct(
                                        dataType: item.localDataType,
                                        label1: label1Text,
                                        label2: label2Text))
                
                
            case .errorMessage:
                
                // append a new record
                localDataBuild.append(item)
                
                
            case .locationService:
                
                // translate the label texts
                let label1Text = NSLocalizedString(item.label1, comment: "")
                let label2Text = "later from LocationService"
                
                // append a new record
                localDataBuild.append(localDataStruct(
                                        dataType: item.localDataType,
                                        label1: label1Text,
                                        label2: label2Text))
                
            }
        }
        
        // get the current error messages
        let (dates, texts) = ErrorList.unique.getCurrentErrors()
        
        // check if we have some
        if dates.isEmpty == false {
            
            // yes, there are messages, so append a header for the list of errors
            let label1Text = NSLocalizedString("Info-Error-Messages",
                                               comment: "List of current error messages")
            
            localDataBuild.append(localDataStruct(
                                    dataType: .singleString,
                                    label1: label1Text,
                                    label2: ""))
            
            
            // walk over the sorted erros and list them
            for index in 0 ..< dates.count {
                
                localDataBuild.append(localDataStruct(
                                        dataType: .doubleString,
                                        label1: dates[index],
                                        label2: texts[index]))
            }
            
        } else {
            
            // No, no errors so far, so give a "no error" message
            let label1Text = NSLocalizedString("Info-No-Error-Messages",
                                               comment: "no error messages")
            
            // append a new record
            localDataBuild.append(localDataStruct(
                                    dataType: .singleString,
                                    label1: "",
                                    label2: label1Text))
        }
        
        DispatchQueue.main.async(execute: {
            
            self.localData = localDataBuild
            
            self.tableView.reloadData()
        })
        
    }
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - IB Outlets
    // ---------------------------------------------------------------------------------------------
    
//    @IBOutlet weak var DoneButton: UIBarButtonItem!
//    @IBAction func DoneButtonAction(_ sender: UIBarButtonItem) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Life cycle
    // ---------------------------------------------------------------------------------------------
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidLoad()
     
     In a tabBar enviroment, switching from tab to tab calls viewDidAppear() always, viewDidLoad() only once
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidAppear()
     
     In a tabBar enviroment, switching from tab to tab calls viewDidAppear() always, viewDidLoad() only once
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // self.title = NSLocalizedString("Main-Button-Help", comment: "Help Button Title")
        self.refreshLocalData()
    }
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Table view data source
    // ---------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     numberOfSections()
     
     -----------------------------------------------------------------------------------------------
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     numberOfRowsInSection:
     
     -----------------------------------------------------------------------------------------------
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.localData.count
    }
    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     willSelectRowAt:
     
     -----------------------------------------------------------------------------------------------
     */
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        // we want the effect, that error messages could be selected, to have some kind of a bookmark, but we do not want that effect in the other infos.
        let row = indexPath.row
        let numberOfInstructions = self.InfoTexts.count
        
        // check if this is a errormessage
        if row > numberOfInstructions {
            
            // yes, it's an error message so allow theselection
            return indexPath
            
        } else {
            
            // no it's not an error message, so do not allow this
            return nil
        }
    }
    
    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     cellForRowAt:
     
     -----------------------------------------------------------------------------------------------
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // dequeue a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell",
                                                 for: indexPath) as! InfoTableViewCell
        
        // get the related data set from local storage
        let index = indexPath.row
        let myData = localData[index]
        
        cell.LabelTop.text = myData.label1
        cell.LabelBottom.text = myData.label2
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
