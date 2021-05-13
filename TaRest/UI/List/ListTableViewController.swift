//
//  ListTableViewController.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 13.05.21.
//

import UIKit

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - List Table View Controller
// -------------------------------------------------------------------------------------------------

final class ListTableViewController: UITableViewController, UISearchResultsUpdating {
   
    
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------------------------
    
    // the oberservers have to be released, otherwise there wil be a memory leak.
    // this variables were set in "ViewDidApear()" and released in "ViewDidDisappear()"
    
    private var newRestaurantDataAvailableObserver: NSObjectProtocol?
    private var globalDataRestoredObserver: NSObjectProtocol?

    
    // this local flag indicates if we have valid data. If we do not have data,
    // we show a pseudo cell with a meaningful message
    
    var flagNoDataAvailable: Bool = true
    
    
    // this are the data we show in the tableView
    var myData : [RestaurantData.dataForListStruct] = []
    var myOldData : [RestaurantData.dataForListStruct] = []
    
    // enum to define the sort strategy
    enum sortStrategyEnum : Int {
        case alphaAscending = 0, alphaDescending = 1, byDistance = 2
    }
    
    // this holds the current sort strategy. the value is permanently stored in Global Data
    var currentSortStrategy: sortStrategyEnum = .alphaAscending
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - IBOutlets
    // ---------------------------------------------------------------------------------------------
    /**
     -----------------------------------------------------------------------------------------------
     
     Sort Button
     
     -----------------------------------------------------------------------------------------------
     */
    @IBOutlet weak var SortButton: UIBarButtonItem!
    @IBAction func SortButtonAction(_ sender: UIBarButtonItem) {
        
        switch self.currentSortStrategy {
        
        case .alphaAscending:
            self.currentSortStrategy = .alphaDescending
            
        case .alphaDescending:
            if GlobalData.unique.LocationServceAllowed == true {
                self.currentSortStrategy = .byDistance
            } else {
                self.currentSortStrategy = .alphaAscending
            }
            
        case .byDistance:
                self.currentSortStrategy = .alphaAscending
        }
        
        GlobalData.unique.UIListTableViewSortStrategy = self.currentSortStrategy.rawValue

        self.handleChangedSortStrategy()
    }
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Search Controller
    // ---------------------------------------------------------------------------------------------

    // we use a search controller to
    private let mySearchController = UISearchController()

    internal func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            print(searchText)
        }
    }
    
    
 

    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Helper
    // ---------------------------------------------------------------------------------------------

    /**
     -----------------------------------------------------------------------------------------------
     
     refreshLocalData()
     
     -----------------------------------------------------------------------------------------------
     */
    private func refreshLocalData() {
        
        // ask RestaurantData for current data
        if let newData = RestaurantData.unique.getDataForList() {
            
            // yes, we have restaurant data, so sort it
            
            var newDataToSort = newData
            switch self.currentSortStrategy {
            
            case .alphaAscending:
                newDataToSort.sort(by: { $0.name < $1.name } )
                
            case .alphaDescending:
                newDataToSort.sort(by: { $0.name > $1.name } )

            case .byDistance:
                newDataToSort.sort(by: { $0.distance > $1.distance } )
            }

            self.reloadMyTableView(newData: newDataToSort)
            
        } else {
            
            // no we do not have any data so far, so set flag "noData" and show a single row with a message
            
            // set the flag and reload data
            DispatchQueue.main.async(execute: {
                self.flagNoDataAvailable = true
                self.tableView.reloadSections([0], with: .automatic)
            })
        }
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     Reloads the tableView, but only if newData are different from myOldData[]
     
     -----------------------------------------------------------------------------------------------
     */
    private func reloadMyTableView(newData: [RestaurantData.dataForListStruct]) {
        
        // yes, we have restaurant data, so check if the data really changed
        if newData.hashValue != self.myOldData.hashValue {
            
            // we use the main thread as arbitary threat tio avoid data races
            DispatchQueue.main.async(execute: {
                
                // replace the data
                self.myData = newData
                self.myOldData = newData
                
                // set the flag
                self.flagNoDataAvailable = false
                
                // reload the table
                //self.tableView.reloadData()
                self.tableView.reloadSections([0], with: .automatic)
            })
            
        } else {
            
            ErrorList.unique.add("ListTableViewController.reloadMyTableView()", .info,
                                 "newData.hashValue == myOldData.hashValue, do not reload data")
        }
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
     - :
     
     - Returns:
     
     */
    private func restoreSortStrategy() {
        
        //
        switch GlobalData.unique.UIListTableViewSortStrategy {
        
        case 0:
            self.currentSortStrategy = .alphaAscending
            
        case 1:
            self.currentSortStrategy = .alphaDescending
            
        case 2:
            if GlobalData.unique.LocationServceAllowed == true {
                self.currentSortStrategy = .byDistance
            } else {
                self.currentSortStrategy = .alphaAscending
            }
            
        default:
            self.currentSortStrategy = .alphaAscending
        }
        
        self.handleChangedSortStrategy()
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     
     
     -----------------------------------------------------------------------------------------------
     */
    private func handleChangedSortStrategy() {
        
        
        var dataToSort = self.myData
        
        switch self.currentSortStrategy {
        
        case .alphaAscending:
            dataToSort.sort(by: { $0.name < $1.name } )
            DispatchQueue.main.async(execute: {
                self.SortButton.image = UIImage(systemName: "chevron.up")
            })
            
        case .alphaDescending:
            dataToSort.sort(by: { $0.name > $1.name } )
            DispatchQueue.main.async(execute: {
                self.SortButton.image = UIImage(systemName: "chevron.down")
            })

        case .byDistance:
            dataToSort.sort(by: { $0.distance > $1.distance } )
            DispatchQueue.main.async(execute: {
                self.SortButton.image = UIImage(systemName: "chevron.up.chevron.down")
            })

        }
        
        self.reloadMyTableView(newData: dataToSort)
        
    }
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Life cycle
    // ---------------------------------------------------------------------------------------------
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidLoad()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //title = "Liste der Restaurants"
        mySearchController.searchResultsUpdater = self
        navigationItem.searchController = mySearchController
        
        self.restoreSortStrategy()
        self.refreshLocalData()

    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidAppear()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        // add observer to recognise if user selcted new state
        if let observer = newRestaurantDataAvailableObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        newRestaurantDataAvailableObserver = NotificationCenter.default.addObserver(
            forName: .TaRest_NewRestaurantDataAvailable,
            object: nil,
            queue: OperationQueue.main,
            using: { Notification in
                
                ErrorList.unique.add("ListTableViewController.viewDidAppear()", .info,
                                     "just recieved signal .TaRest_NewRestaurantDataAvailable, call refreshLocalData()")

                self.refreshLocalData()
            })
      
        // add observer to recognise if global data are restored (for sort strategy)
        if let observer = globalDataRestoredObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        globalDataRestoredObserver = NotificationCenter.default.addObserver(
            forName: .TaRest_GlobalDataRestored,
            object: nil,
            queue: OperationQueue.main,
            using: { Notification in
                
                ErrorList.unique.add("ListTableViewController.viewDidAppear()", .info,
                                     "just recieved signal .TaRest_GlobalDataRestored, call restoreSortStrategy()")

                self.restoreSortStrategy()
            })

        self.refreshLocalData()

    }
 
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidDisappear()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        
        // remove the observer if set
        if let observer = newRestaurantDataAvailableObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = globalDataRestoredObserver {
            NotificationCenter.default.removeObserver(observer)
        }
      
   }

    /**
     -----------------------------------------------------------------------------------------------
     
     deinit
     
     -----------------------------------------------------------------------------------------------
     */
    deinit {

        // remove the observer if set
        if let observer = newRestaurantDataAvailableObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = globalDataRestoredObserver {
            NotificationCenter.default.removeObserver(observer)
        }

    }


    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Table view data source
    // ---------------------------------------------------------------------------------------------

    /**
     -----------------------------------------------------------------------------------------------
     
     numberOfSections:
     
     -----------------------------------------------------------------------------------------------
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     numberOfSections:
     
     -----------------------------------------------------------------------------------------------
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // check if we have valid data
        if self.flagNoDataAvailable == true {
            
            // no we do not have valid data, so enable one cell for the "no data cell"
            return 1
            
        } else {
            
            // count the items and return the number
            return self.myData.count
        }
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     numberOfSections:
     
     -----------------------------------------------------------------------------------------------
     */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // check if we have to create a pseudo cell
        if self.flagNoDataAvailable == true {
            
            // create a pseudo cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCellNoData",
                                                     for: indexPath) as! ListTableViewCellNoData
            
            // set a meaningfull message
            cell.Message.text = NSLocalizedString("List-No-Data-Sofar",
                                                  comment: "Message that we do not have any restaurant data so far")
            
            // return what we have
            return cell
            
        } else {
            
            let index = indexPath.row
            let item = self.myData[index]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell",
                                                     for: indexPath) as! ListTableViewCell
            
            // set the IBOutlets of the cell
            cell.ThumbImage.image = item.image
            cell.Name.text = item.name
            cell.IsOpen.text = item.isOpen
            cell.Flags.text = item.flags

            // return what we have
            return cell
        }
        
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
