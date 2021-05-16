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

final class DetailViewController: UIViewController, MKMapViewDelegate {
    
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
    
    
    @IBOutlet weak var day0: UILabel!
    @IBOutlet weak var open0: UILabel!
    
    @IBOutlet weak var day1: UILabel!
    @IBOutlet weak var open1: UILabel!
    
    @IBOutlet weak var day2: UILabel!
    @IBOutlet weak var open2: UILabel!
    
    @IBOutlet weak var day3: UILabel!
    @IBOutlet weak var open3: UILabel!
    
    @IBOutlet weak var day4: UILabel!
    @IBOutlet weak var open4: UILabel!
    
    @IBOutlet weak var day5: UILabel!
    @IBOutlet weak var open5: UILabel!
    
    @IBOutlet weak var day6: UILabel!
    @IBOutlet weak var open6: UILabel!
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - MapKit Delegate
    // ---------------------------------------------------------------------------------------------

    /**
     -----------------------------------------------------------------------------------------------
     
     viewFor annotation:
     
     here used to set the tintColor to our AccentColor and set the symbol to our restaurant sign
     
     -----------------------------------------------------------------------------------------------
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // get a view
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyAnnotationView")
        
        // set color and image
        annotationView.markerTintColor = UIColor(named: "AccentColor") ?? UIColor.systemRed
        annotationView.glyphImage = UIImage(named: "Annotation image 64")
        
        // we set a cluster identifier, which might be useful
        annotationView.clusteringIdentifier = "TaRest"
        
        // we want the subtitle visible
        annotationView.subtitleVisibility = .visible
        
        // and we do not want a call out here
        annotationView.canShowCallout = false
        
        // return what we have
        return annotationView
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
        
        // Do any additional setup after loading the view.
        
        // we do all the setting here, as this is a very limited view, no need for a seperate set up function.
        
        // get the data to show
        let item = RestaurantData.unique.getDataForDetail(self.indexOfRestaurantToShowDetails)
        
        // -----------------------------------------------------------------------------------------
        // set the IBOutlets
        // -----------------------------------------------------------------------------------------

        self.Name.text = item.name
        self.IsOpen.text = item.isOpen
        self.Flags.text = item.flags
        
        self.FullSizeImage.image = item.image
        
        self.day0.text  = item.openHoursDays[0]
        self.open0.text = item.openHoursValues[0]
        
        self.day1.text  = item.openHoursDays[1]
        self.open1.text = item.openHoursValues[1]
        
        self.day2.text  = item.openHoursDays[2]
        self.open2.text = item.openHoursValues[2]
        
        self.day3.text  = item.openHoursDays[3]
        self.open3.text = item.openHoursValues[3]
        
        self.day4.text  = item.openHoursDays[4]
        self.open4.text = item.openHoursValues[4]
        
        self.day5.text  = item.openHoursDays[5]
        self.open5.text = item.openHoursValues[5]
        
        self.day6.text  = item.openHoursDays[6]
        self.open6.text = item.openHoursValues[6]
       
        
        // -----------------------------------------------------------------------------------------
        // set up the map
        // -----------------------------------------------------------------------------------------

        self.MyMap.delegate = self
        
        self.MyMap.setRegion(
            MKCoordinateRegion(
                center: item.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)),
            animated: false)
        
        
        // -----------------------------------------------------------------------------------------
        // show the retaurant on the map as an point annotation
        // -----------------------------------------------------------------------------------------
        
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = item.coordinate
        myAnnotation.title = item.name
        myAnnotation.subtitle = item.isOpen
         
        self.MyMap.addAnnotation(myAnnotation)

    }
}
