//
//  MainTabBarController.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 12.05.21.
//

import UIKit


// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - MainTabBarController
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Class
// -------------------------------------------------------------------------------------------------
final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Properties
    // ---------------------------------------------------------------------------------------------
    
    // we use the property "selectedIndex" of the UITabBarController class to (re)set the selected tab
    // this value is stored in the user defaults
    
    // the oberservers have to be released, otherwise there will be a memory leak.
    // this variables were set in "ViewDidApear()" and released in "ViewDidDisappear()"
    
    // this view is sometimes already loaded (and set) before the UISettings were restored (DataRace)
    // so we have a noticifaction to reset the UI after we restored the data
    private var GlobalDataRestoredObserver: NSObjectProtocol?
    private var UIDataAreRestored: Bool = false
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Helpers
    // ---------------------------------------------------------------------------------------------
        
    /**
     -----------------------------------------------------------------------------------------------
     
     Set the the index
     
     -----------------------------------------------------------------------------------------------
     */
    private func refreshAfterUIDataRestored() {
        
        // as we change the UI, use main threat
        DispatchQueue.main.async(execute: {
            
            // restore the selcted tab
            self.selectedIndex = GlobalData.unique.UIMainTabBarSelectedTab
        })
    }
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Tab bar delegate
    // ---------------------------------------------------------------------------------------------
    override func tabBar(_: UITabBar, didSelect: UITabBarItem) {
        
        // we have to search for the selected item, as self.selectedIndex has still the old value
        // so loop over the tabbars
        for index in 0 ..< self.tabBar.items!.count {
            
            // get the current one
            let item = self.tabBar.items![index]
            
            // check the title and if it is changed
            if (item.title == didSelect.title)
                && (index != GlobalData.unique.UIMainTabBarSelectedTab) {
                
                // we found it and it changed, so save it
                GlobalData.unique.UIMainTabBarSelectedTab = index

                // we can break the loop
                break
            }
        }
    }
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Life Cycle
    // ---------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidLoad()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        ErrorList.unique.add("MainTabBarController.viewDidLoad()", .info,
                             "Just started")
        
        // restore the selcted tab
        self.selectedIndex = GlobalData.unique.UIMainTabBarSelectedTab
        
        // set the delegate so we will be informed after tabs are selected
        self.delegate = self
    }
    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidAppear()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
    }
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidAppear()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        // Do any additional setup after loading the view.
        
        
        // add observer to recognise if gloabal data has restored its values
        if let observer = GlobalDataRestoredObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        GlobalDataRestoredObserver = NotificationCenter.default.addObserver(
            forName: .TaRest_GlobalDataRestored,
            object: nil,
            queue: OperationQueue.main,
            using: { Notification in
                
                // refresh the tab bar item titels to reflect the new selection by user
                self.refreshAfterUIDataRestored()
                
                ErrorList.unique.add("MainTabBarController.GlobalDataRestoredObserver()", .info,
                                     "just recieved signal .TaRest_GlobalDataRestored")
                
            })
        
        DispatchQueue.main.async(execute: {
            // and to avoid a dataRace at all
            // restore the selcted tab
            self.selectedIndex = GlobalData.unique.UIMainTabBarSelectedTab
        })
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidDisappear()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        
        // remove the observer if set
        if let observer = GlobalDataRestoredObserver {
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
        if let observer = GlobalDataRestoredObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
