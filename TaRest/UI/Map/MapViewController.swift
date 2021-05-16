//
//  MapViewController.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 12.05.21.
//

import UIKit
import MapKit

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - MapViewController
// -------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Class
// -------------------------------------------------------------------------------------------------
class MapViewController: UIViewController, MKMapViewDelegate {
    
    // ---------------------------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------------------------
    // the oberserver have to be released, otherwise there wil be a memory leak.
    // this variable were set in "ViewDidApear()" and released in "ViewDidDisappear()"
    private var GlobalDataRestoredObserver: NSObjectProtocol?
    private var newRestaurantDataAvailableObserver: NSObjectProtocol?
    private var didEnterBackgroundObserver: NSObjectProtocol?
    
    
    // int to mark the current selected content
    private var myMapContentMark: Int = 0
    
    // this will hold dictonary of the annotation name and the index of the restaurant in RestaurantData.DataArray[]
    // we use this to call the detailViewController
    private var annotationIndexDic: [String : Int] = [:]
    
    // we use this variable to indicate the called detailViewController, which content it should show (segue)
    private var indexOfRestaurantToShowDetails : Int = -1
    private let segueShowDetailFromMap : String = "ShowDetailFromMap"

    // ---------------------------------------------------------------------------------------------
    // MARK: - UI Outlets
    // ---------------------------------------------------------------------------------------------

    // The map itself
    @IBOutlet weak var MyMapView: MKMapView!
     
    
    // ---------------------------------------------------------------------------------------------
    // MARK: ContentButton
    // ---------------------------------------------------------------------------------------------

    // ---------------------------------------------------------------------------------------------
    // the button change map content (e.g. satelite)
    @IBOutlet weak var ContentButton: UIButton!
    @IBAction func ContentButtonAction(_ sender: UIButton) {
            
        self.myMapContentMark += 1
        if self.myMapContentMark > 1 {
            self.myMapContentMark = 0
        }
        
        // make it permanent
        GlobalData.unique.MapContentMark = self.myMapContentMark
        
        // change the map
        self.setMapTypeOnScreen()
    }

    // ---------------------------------------------------------------------------------------------
    // MARK: HeadingButton
    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
    // the button change map heading
    @IBOutlet weak var HeadingButton: UIButton!
    @IBAction func HeadingButtonAction(_ sender: UIButton) {
            
        // TODO: TODO: Button is disabled in ViewDidLoad()
    }


    // ---------------------------------------------------------------------------------------------
    // MARK: PlusButton
    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
    // the button to zoom in
    var PlusButtonActionAlreadyTriggered : Bool = false
    @IBOutlet weak var PlusButton: UIButton!
    @IBAction func PlusButtonAction(_ sender: UIButton) {
            
        if PlusButtonActionAlreadyTriggered == false {
            
            // we have to slow down the "tap-rate", otherwise the main Thread might get overwelmed and the screen refresh stucked
            // so we call the main action after 0.1 seconds and ignore every additional tap until than
            PlusButtonActionAlreadyTriggered = true
            
            // get the current region
            let currentRegion = self.MyMapView.region
            
            // some calculations
            let currentCenter = currentRegion.center
            let currentSpanLatitude = currentRegion.span.latitudeDelta
            let currentSpanLongitude = currentRegion.span.longitudeDelta
            
            // Calculate the new latitude value and check against max possible (it crashes if value < 0)
            var newSpanLatitude = currentSpanLatitude / 2.0
            if newSpanLatitude < 0.0 { newSpanLatitude = 0.0 }
            
            // Calculate the new longitude value and check against max possible (it crashes if value < 0)
            var newSpanLongitude = currentSpanLongitude / 2.0
            if newSpanLongitude < 0.0 { newSpanLongitude = 0.0 }
            
            // generate the new span
            let newSpan = MKCoordinateSpan(latitudeDelta: newSpanLatitude,
                                           longitudeDelta: newSpanLongitude)
            
            // generate the new region
            let newRegion = MKCoordinateRegion(center: currentCenter, span: newSpan)
            let regionThatFits = self.MyMapView.regionThatFits(newRegion)
            
            // set the new region
            let newCenter = CLLocationCoordinate2D(latitude: regionThatFits.center.latitude + 0.1,
                                                   longitude: regionThatFits.center.longitude)
            
            DispatchQueue.main.async(execute: {
                
                // meanwhile the map might have been disapeared
                if self.MyMapView != nil {
                    
                    // does not work with "animated: true" ...
                    self.MyMapView.setCenter(regionThatFits.center, animated: false)
                    self.MyMapView.setRegion(regionThatFits, animated: false)
                    
                    // to refresh the scale on the map we have to move the map back and forth
                    self.MyMapView.setCenter(newCenter, animated: false)
                    self.MyMapView.setCenter(regionThatFits.center, animated: false)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100) , execute: {
                    self.PlusButtonActionAlreadyTriggered = false
                })
            })
        }
    }
    
    // ---------------------------------------------------------------------------------------------
    // MARK: CenterButton
    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
    // the button to center map on current location or center of all restaurants
    @IBOutlet weak var CenterButton: UIButton!
    @IBAction func CenterButtonAction(_ sender: UIButton) {
            
        // TODO: TODO: Button is disabled in ViewDidLoad()
    }
    
    // ---------------------------------------------------------------------------------------------
    // MARK: MinusButton
    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
    // the button to zoom in
    var MinusSignActionAlreadyTriggered: Bool = false
    @IBOutlet weak var MinusButton: UIButton!
    @IBAction func MinusButtonAction(_ sender: UIButton) {
        
        // we have to slow down the "tap-rate", otherwise the main Thread might get overwelmed and the screen refresh stucked
        // so we call the main action after 0.1 seconds and ignore every additional tap until than
        if MinusSignActionAlreadyTriggered == false {
            
            MinusSignActionAlreadyTriggered = true
            
            // get the current region
            let currentRegion = self.MyMapView.region
            
            // some calculations
            let currentCenter = currentRegion.center
            let currentSpanLatitude = currentRegion.span.latitudeDelta
            let currentSpanLongitude = currentRegion.span.longitudeDelta
            
            // Calculate the new latitude value and check against max possible (it crashes if value > 180)
            var newSpanLatitude = currentSpanLatitude * 2.0
            if newSpanLatitude > 180.0 { newSpanLatitude = 180.0 }
            
            // Calculate the new longitude value and check against max possible (it crashes if value > 360)
            var newSpanLongitude = currentSpanLongitude * 2.0
            if newSpanLongitude > 360.0 { newSpanLongitude = 360.0 }
            
            // generate the new span
            let newSpan = MKCoordinateSpan(latitudeDelta: newSpanLatitude,
                                           longitudeDelta: newSpanLongitude)
            
            // generate the new region
            let newRegion = MKCoordinateRegion(center: currentCenter, span: newSpan)
            let regionThatFits = self.MyMapView.regionThatFits(newRegion)
            
            // set the new region
            let newCenter = CLLocationCoordinate2D(latitude: regionThatFits.center.latitude + 0.1, longitude: regionThatFits.center.longitude)
            
            //DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100) , execute: {
            DispatchQueue.main.async(execute: {
                
                // meanwhile the map might have been disapeared
                if self.MyMapView != nil {
                    
                    self.MyMapView.setCenter(regionThatFits.center, animated: false)
                    self.MyMapView.setRegion(regionThatFits, animated: false)
                    
                    // to refresh the scale on the map we have to move the map back and forth
                    self.MyMapView.setCenter(newCenter, animated: false)
                    self.MyMapView.setCenter(regionThatFits.center, animated: false)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100) , execute: {
                        self.MinusSignActionAlreadyTriggered = false
                    })
                }
            })
        }
    }

    
    // ---------------------------------------------------------------------------------------------
    // MARK: - UI Helpers
    // ---------------------------------------------------------------------------------------------
    
    /**
     -----------------------------------------------------------------------------------------------
     
     setMapTypeOnScreen()
     
     -----------------------------------------------------------------------------------------------
     */
    func setMapTypeOnScreen() {
        
        switch myMapContentMark {
        case 0: // map
            DispatchQueue.main.async(execute: {
                
                if self.MyMapView != nil {
                    
                    self.MyMapView.mapType = MKMapType.mutedStandard
                    self.MyMapView.pointOfInterestFilter = .includingAll
                }
            })
            
            
        case 1: // hybrid
            DispatchQueue.main.async(execute: {
                
                if self.MyMapView != nil {
                    self.MyMapView.mapType = MKMapType.hybrid
                    self.MyMapView.pointOfInterestFilter = .includingAll
                }
            })
            
            
        default:
            ErrorList.unique.add("MapViewController.setMapTypeOnScreen()", .error,
                                 "got a not valid MapType, set it to standard, store it and call setMapTypeOnScreen() again")
            
            myMapContentMark = 0
            GlobalData.unique.MapContentMark = myMapContentMark
            
            setMapTypeOnScreen()
        }
    }

    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     restoreMapSettings()
     
     build the map region to display and show it on the map
     
     -----------------------------------------------------------------------------------------------
     */
    private func restoreMapSettings() {
        
        // get the data and build the region
        let centerOfMap = GlobalData.unique.UIMapLastCenterCoordinate
        let regionToDisplay = MKCoordinateRegion(center: centerOfMap,
                                                 span: GlobalData.unique.UIMapLastSpan)
        
        // set the map
        DispatchQueue.main.async(execute: {
            self.MyMapView.setCenter(centerOfMap, animated: false)
            self.MyMapView.setRegion(regionToDisplay, animated: false)
        })
        
        // make it permanent
        self.myMapContentMark = GlobalData.unique.MapContentMark
        
        // change the map
        self.setMapTypeOnScreen()
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     saveMapSettings()
     
     -----------------------------------------------------------------------------------------------
     */
    private func saveMapSettings() {
        
        // save the center coordinate and span persistent
        if let myMap = self.MyMapView {
            GlobalData.unique.UIMapLastCenterCoordinate = myMap.centerCoordinate
            GlobalData.unique.UIMapLastSpan = myMap.region.span
        }
    }

    
    // ---------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: - MapKit Delegate
    // ---------------------------------------------------------------------------------------------

    /**
     -----------------------------------------------------------------------------------------------
     
     
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
     - :
     
     - Returns:
     
     */
    private func refreshMapAnnotations() {
        
        
        // get the current restaurant data
        let newData = RestaurantData.unique.getDataForMap()
        
        // we build all annotations in an array
        var newAnnotations: [MKPointAnnotation] = []
        
        // this will be the new dictonary of the restaurant names and indexes
        var newDictonary: [String : Int] = [:]
        
        // build the new annotations
        for item in newData {
            
            // build the annotation and set the properties
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = item.coordinate
            newAnnotation.title = item.name
            newAnnotation.subtitle = item.isOpen

            // add it to the array of new annotations
            newAnnotations.append(newAnnotation)
            
            // append a dictonary entry. "item.Index" is the index of the restaurant in RestaurantData.DataArray[]
            newDictonary[item.name] = item.index
        }
        
        // replace the annotations, as we change the UI we do it on main threat
        DispatchQueue.main.async(execute: {
            
            // first remove all old annotations
            let myOldAnnotations = self.MyMapView.annotations.filter( { $0 is MKPointAnnotation})
            if myOldAnnotations.isEmpty == false {
                self.MyMapView.removeAnnotations(myOldAnnotations)
            }
            
            // exchange the dictonary
            self.annotationIndexDic = newDictonary
            
            // add the new annotations
            self.MyMapView.addAnnotations(newAnnotations)
        })
    }
    
    
    
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
        
        // and we want a call out ...
        annotationView.canShowCallout = true
        
        // ... with a button indicator
        let myButton : UIButton = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = myButton
        
        
        // return what we have
        return annotationView
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     
     
     -----------------------------------------------------------------------------------------------
     
     - Parameters:
     - :
     
     - Returns:
     
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let title = view.annotation?.title {
            
            if let possibleIndex = self.annotationIndexDic[title!] {
                
                self.indexOfRestaurantToShowDetails = possibleIndex
                
                performSegue(withIdentifier: self.segueShowDetailFromMap, sender: self)
            }
        }
    }

    
    // ---------------------------------------------------------------------------------------------
    // MARK: -
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
        
        self.MyMapView.delegate = self
        
        self.MyMapView.isRotateEnabled = true
        self.MyMapView.isPitchEnabled = true
        
        // hide unused buttons
        // TODO: TODO: buttons still disabled
        self.CenterButton.isHidden = true
        self.CenterButton.isEnabled = false
        
        self.HeadingButton.isHidden = true
        self.HeadingButton.isEnabled = false
         
        // build the map region to display and show it on the map
        self.restoreMapSettings()
        
        // refresh the annotations
        self.refreshMapAnnotations()

    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidAppear()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        
        // add observer to recognise if gloabal data has restored its values
        if let observer = self.GlobalDataRestoredObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        self.GlobalDataRestoredObserver = NotificationCenter.default.addObserver(
            forName: .TaRest_GlobalDataRestored,
            object: nil,
            queue: OperationQueue.main,
            using: { Notification in
                
                ErrorList.unique.add("MapViewController.GlobalDataRestoredObserver()", .info,
                                     "MapViewController just recieved signal .TaRest_GlobalDataRestored, call resetMapRegion()")
                
                self.restoreMapSettings()
            })
        
        // observer if new restaurant data available
        if let observer = self.newRestaurantDataAvailableObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        newRestaurantDataAvailableObserver = NotificationCenter.default.addObserver(
            forName: .TaRest_NewRestaurantDataAvailable,
            object: nil,
            queue: OperationQueue.main,
            using: { Notification in
                
                ErrorList.unique.add("MapViewController.newRestaurantDataAvailableObserver()", .info,
                                     "just recieved signal .TaRest_NewRestaurantDataAvailable, call refreshMapAnnotations()")

                self.refreshMapAnnotations()
            })
        
        
        if let observer = self.didEnterBackgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        didEnterBackgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { Notification in
                
                ErrorList.unique.add("MapViewController.didEnterBackgroundObserver()", .info,
                                     "just recieved signal .didEnterBackgroundObserver, call saveMapSettings()")

                self.saveMapSettings()
            })

        
        
        // refresh the annotations
        self.refreshMapAnnotations()

    }
 
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidDisappear()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        
        // remove the observer if set
        if let observer = self.GlobalDataRestoredObserver {
           NotificationCenter.default.removeObserver(observer)
       }

        if let observer = self.newRestaurantDataAvailableObserver {
           NotificationCenter.default.removeObserver(observer)
       }
        
        if let observer = self.didEnterBackgroundObserver {
           NotificationCenter.default.removeObserver(observer)
       }

        
        
        // save the center coordinate and span persistent
        self.saveMapSettings()

    }

    /**
     -----------------------------------------------------------------------------------------------
     
     deinit
     
     -----------------------------------------------------------------------------------------------
     */
    deinit {
        
        // remove the observer if set
        if let observer = self.GlobalDataRestoredObserver {
           NotificationCenter.default.removeObserver(observer)
       }

        if let observer = self.newRestaurantDataAvailableObserver {
           NotificationCenter.default.removeObserver(observer)
       }

        if let observer = self.didEnterBackgroundObserver {
           NotificationCenter.default.removeObserver(observer)
       }


        // save the center coordinate and span persistent
        self.saveMapSettings()

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
        
        if segue.identifier == self.segueShowDetailFromMap {

            // get the view controller
            let navigationViewController = segue.destination as! UINavigationController
            let destinationViewController =
                navigationViewController.topViewController as! DetailViewController

            // set the index to show
            destinationViewController.indexOfRestaurantToShowDetails = self.indexOfRestaurantToShowDetails
        }
    }
}


