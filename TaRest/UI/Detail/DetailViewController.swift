//
//  DetailViewController.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 14.05.21.
//

import UIKit
import MapKit


// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Detail View Controller
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Class
// -------------------------------------------------------------------------------------------------

final class DetailViewController: UIViewController {
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------------------------
    
    // this will be set by the calling view controller.
    // DetailViewController will call RestaurantData.unique.
    public var indexOfRestaurantToShowDetails: Int = -1
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - IB Outlets
    // ---------------------------------------------------------------------------------------------
    
    @IBAction func DoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var IsOpen: UILabel!
    @IBOutlet weak var Flags: UILabel!
    
    @IBOutlet weak var FullSizeImage: UIImageView!
    
    @IBOutlet weak var MyMap: MKMapView!
    
    
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
        
        // Do any additional setup after loading the view.
        
        // get the data to show
        let item = RestaurantData.unique.getDataForDetail(self.indexOfRestaurantToShowDetails)
        
        self.Name.text = item.name
        self.IsOpen.text = item.isOpen
        self.Flags.text = item.flags
        
        self.FullSizeImage.image = item.image
        
        self.MyMap.setCenter(item.coordinate, animated: false)
        
    }
}
