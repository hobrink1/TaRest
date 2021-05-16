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
    

    // we use a search controller to highlight and filter
    private let mySearchController = UISearchController(searchResultsController: nil)
    
    // this is the current searchText the user keyed in
    private var currentSearchText = ""

    // we highlight the part of the restaurant name which matches to the currentSearchText
    // this are the parameter for this highlighting
    private let highLightForegroundColor: UIColor = UIColor(named: "AccentColor") ?? UIColor.systemRed
    private let highLightBackgroundColor: UIColor = UIColor.systemGray6
    private let highLightFont: UIFont = .preferredFont(forTextStyle: .title2) // font has to match with main.storyboard

    
    // we use this variable to indicate the called detailViewController, which content it should show (segue)
    private var indexOfRestaurantToShowDetails : Int = -1
    private let segueShowDetailFromList : String = "ShowDetailFromList"
    
    // this are the data we show in the tableView (myData[] might be filtered of myOldData[])
    private var myData : [RestaurantData.dataForListStruct] = []
    private var myOldData : [RestaurantData.dataForListStruct] = []
    private var myDataSortedUnfiltered : [RestaurantData.dataForListStruct] = []
    
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

    /**
     -----------------------------------------------------------------------------------------------
     
     
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
     - :
     
     - Returns:
     
     */
    internal func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            currentSearchText = searchText
        } else {
            currentSearchText = ""
        }
        
        DispatchQueue.main.async(execute: {
            
            self.filterContenBySearchString()
            
            self.tableView.reloadData()
        })
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
     - :
     
     - Returns:
     
     */
    private func filterContenBySearchString() {
    
        if self.currentSearchText == "" {
            
            self.myData = self.myDataSortedUnfiltered
            
        } else {
            
            self.myData = self.myDataSortedUnfiltered.filter(
                {
                    (item: RestaurantData.dataForListStruct) -> Bool in
                    return item.name.lowercased().contains(self.currentSearchText.lowercased())
                })
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
            
            // check if the data changed
            if newData.hashValue != self.myOldData.hashValue {
                
                // yes, new data, save it for the next time
                self.myOldData = newData
                
                // sort it
                var newDataToSort = newData
                switch self.currentSortStrategy {
                
                case .alphaAscending:
                    newDataToSort.sort(by: { $0.name < $1.name } )
                    
                case .alphaDescending:
                    newDataToSort.sort(by: { $0.name > $1.name } )
                    
                case .byDistance:
                    newDataToSort.sort(by: { $0.distance > $1.distance } )
                }
                
                self.reloadMyTableViewWithNewData(newData: newDataToSort)
                
            } else {
                
                ErrorList.unique.add("ListTableViewController.refreshLocalData()", .info,
                                     "newData.hashValue == myOldData.hashValue, do not reload data")
            }
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
    private func reloadMyTableViewWithNewData(newData: [RestaurantData.dataForListStruct]) {
        
             // we use the main thread as arbitary threat tio avoid data races
            DispatchQueue.main.async(execute: {
                
                // replace the data
                self.myDataSortedUnfiltered = newData
                
                self.filterContenBySearchString()
                                
                // set the flag
                self.flagNoDataAvailable = false
                
                // reload the table
                //self.tableView.reloadData()
                self.tableView.reloadSections([0], with: .automatic)
            })
            
        
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
        
        self.reloadMyTableViewWithNewData(newData: dataToSort)
        
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
        
        // setup for the searchController
        // this class will act as the resultsUpdater
        mySearchController.searchResultsUpdater = self
        
        // we do not want to obscure our view
        mySearchController.obscuresBackgroundDuringPresentation = false
        
        // placeholder to show in the search filed
        mySearchController.searchBar.placeholder = "Restaurant"
        
        // use this search controller only in this context
        definesPresentationContext = true
        
        // add it to the navigation bar
        navigationItem.searchController = mySearchController
        
        
        // now restore the user settings of the last session
        self.restoreSortStrategy()
        
        // and finally refresh the data
        self.refreshLocalData()

    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidAppear()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        // add observer to recognise new restaurants
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
     
     numberOfRowsInSection:
     
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
     
     cellForRowAt:
     
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
            
            // highlight the searchText
            let attributedText = item.name.highlightText(
                self.currentSearchText,
                foregroundColor: highLightForegroundColor,
                backgroundColor: highLightBackgroundColor,
                font: highLightFont)
             
            cell.Name.attributedText = attributedText
           
            // set the IBOutlets of the cell
            cell.ThumbImage.image = item.image
            cell.IsOpen.text = item.isOpen
            cell.Flags.text = item.flags

            // set the hint, that user can see details
            cell.accessoryType = .disclosureIndicator
            
            // return what we have
            return cell
        }
    }
     
    /**
     -----------------------------------------------------------------------------------------------
     
     accessoryButtonTappedForRowWith:
     
     -----------------------------------------------------------------------------------------------
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // we deselect the cell, as requested by Apple (as I heared)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        // check if we have valid data
        if self.flagNoDataAvailable == true {
            
            // no, we do not have valid data, so do nothing and return
            return
        }
        
        // if we reach here, we are able to  call the detail view
        
        // get the related data set
        let item = self.myData[indexPath.row]
        
        // set the index of the restaurant in RestaurantData.DataArray[]
        self.indexOfRestaurantToShowDetails = item.index
        
        print("selected entry: name local: \"\(item.name)\", name global \"\(RestaurantData.unique.DataArray[self.indexOfRestaurantToShowDetails].name)\"")
        
        self.performSegue(withIdentifier: segueShowDetailFromList, sender: self)

    }
    
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Navigation
    // ---------------------------------------------------------------------------------------------

    /**
     -----------------------------------------------------------------------------------------------
     
     prepare for:
     
     -----------------------------------------------------------------------------------------------
     */
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == self.segueShowDetailFromList {

            // get the view controller
            let navigationViewController = segue.destination as! UINavigationController
            let destinationViewController =
                navigationViewController.topViewController as! DetailViewController

            // set the index to show
            destinationViewController.indexOfRestaurantToShowDetails = self.indexOfRestaurantToShowDetails
        }
    }
    
}
