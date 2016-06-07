//
//  ViewController.swift
//  GPS Wars
//
//  Created by Matthew Krager on 12/26/15.
//  Copyright © 2015 Matthew Krager. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    var backendless = Backendless()
    var machines: NSMutableArray = NSMutableArray()
    let clusteringManager = FBClusteringManager()
    
    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidAppear(animated: Bool) {
        self.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("REQUESTS")
        // self.mapView.
        //// self.mapView. = self
        // Location manager
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        self.mapView.showsUserLocation = true
        // Current Location span
        if let locValue:CLLocationCoordinate2D = self.locationManager.location?.coordinate {
            let latitude:CLLocationDegrees = locValue.latitude
            let longitude:CLLocationDegrees = locValue.longitude
            let latDelta:CLLocationDegrees = 0.03
            let lonDelta:CLLocationDegrees = 0.03
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            mapView.setRegion(region, animated: false)
        }
        
        // Set up gestures to refresh when panned or display info when tapped
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapMap:")
        self.mapView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "didPanMap:")
        panGesture.delegate = self
        self.mapView.addGestureRecognizer(panGesture)
        
        // Nav SetUp
        let navigationBar = navigationController!.navigationBar
        navigationBar.tintColor = Colors.colorWithHexString("#00B0FF")
        
        navigationItem.leftBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh"), MKUserTrackingBarButtonItem(mapView: self.mapView)]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewArcadeMachine")
        
        /* let machine = ArcadeMachine()
        machine.name = "DDR Mega Mix "
        machine.arcadeName = "Kragers Arcade"
        machine.geoPoint = GeoPoint.geoPoint(
        GEO_POINT(latitude: 33.71 , longitude: -118.03)
        ) as? GeoPoint
        backendless.persistenceService.of(ArcadeMachine.ofClass()).save(machine)
        */
        /* backendless.geoService.savePoint(
        houstonTX,
        response: { (var point : GeoPoint!) -> () in
        print("ASYNC: geo point saved. Object ID - \(point.objectId)")
        },
        error: { (var fault : Fault!) -> () in
        print("Server reported an error: \(fault)")
        }
        )*/
        //backendless.persistenceService.of(ArcadeMachine.ofClass()).sa
    }
    
    func addNewArcadeMachine() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SearchForName") as! SearchForNameTableViewController
        self.showViewController(vc, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refresh() {
        if abs(self.mapView.region.span.latitudeDelta) < 10000.6 && abs(self.mapView.region.span.longitudeDelta) < 10000.8 {
            let nwPoint = CGPointMake(self.mapView.bounds.origin.x - 100, mapView.bounds.origin.y - 100);
            let sePoint = CGPointMake((self.mapView.bounds.origin.x + self.mapView.bounds.size.width + 100), (mapView.bounds.origin.y + mapView.bounds.size.height) + 100);
            // Transform points into lat,lng values
            let nwCoord = self.mapView.convertPoint(nwPoint, toCoordinateFromView: self.mapView)
            let seCoord = self.mapView.convertPoint(sePoint, toCoordinateFromView: self.mapView)
            
            // print(nwCoord)
            //print(seCoord)
            // Search backendless for machines in the view
            //var query2 = BackendlessDataQuery
            let queryOptions = QueryOptions()
            queryOptions.addRelated("geoPoint")
            queryOptions.pageSize = 50
            //queryOptions.so
            let query = BackendlessDataQuery()
            query.queryOptions = queryOptions
            query.whereClause = "geoPoint.latitude < \(nwCoord.latitude) AND geoPoint.latitude > \(seCoord.latitude) AND geoPoint.longitude > \(nwCoord.longitude) AND geoPoint.longitude < \(seCoord.longitude)"
            
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0), { () -> Void in
                //print("Taco")
                Types.tryblock({ () -> Void in
                let machinesSearched: BackendlessCollection! = self.backendless.data.of(ArcadeMachine.ofClass()).find(query)
                    
                    
                let currentPage = machinesSearched.getCurrentPage()
                print("Loaded \(currentPage.count) machine objects")
                print("Thread \(NSThread.currentThread())")
                for machine in currentPage {
                    //print("name = \(machine.name)")
                    //print("\(machine.objectId)")
                    //print(machine.geoPoint)
                    let overlay = ArcadeMachineMkCircle(centerCoordinate: CLLocationCoordinate2D(latitude: ((machine.geoPoint as GeoPoint).latitude as Double), longitude: ((machine.geoPoint as GeoPoint).longitude as Double)), radius: 20)
                    overlay.setArcadeMachine(machine as! ArcadeMachine)
                    var isAlreadyThere = false
                    for current in self.clusteringManager.allAnnotations() as! [ArcadeMachineMkCircle] {
                        if current.machine?.geoPoint?.latitude == overlay.machine?.geoPoint?.latitude {
                            if current.machine?.geoPoint?.longitude == overlay.machine?.geoPoint?.longitude {
                                if current.machine?.name == overlay.machine?.name {
                                    isAlreadyThere = true
                                }
                            }
                        }
                    }
                    if !isAlreadyThere {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            //self.mapView.addOverlay(overlay)
                            //self.mapView.addAnnotation(overlay)
                            self.clusteringManager.addAnnotations([overlay])
                        })
                    }
                }
                }, catchblock: { (exception) -> Void in
                    print(exception)
                })
                
                
            })
            
           
        }
    }
    
    func didPanMap(gestureRecognizer: UIGestureRecognizer) {
        // If the tap is ending (prevents double reload)
        if gestureRecognizer.state == .Ended {
            refresh()
        }
    }
    
    func didTapMap(gestureRecognizer: UIGestureRecognizer) {
        // Only register when a tap has ended
        if gestureRecognizer.state == .Ended {
            // Convert the tap into lat and long
            let tapPoint: CGPoint = gestureRecognizer.locationInView(self.mapView)
            let tapCoordinate = self.mapView.convertPoint(tapPoint, toCoordinateFromView: self.mapView)
            let tapMapPoint = MKMapPointForCoordinate(tapCoordinate)
            // Find if we tapped any arcade machines
            for overlay in self.mapView.overlays{
                if (overlay.isKindOfClass(MKCircle)) {
                    let circle = overlay as! MKCircle
                    let circleCenterMapPoint = MKMapPointForCoordinate(circle.coordinate)
                    let distanceFromCircleCenter = MKMetersBetweenMapPoints(circleCenterMapPoint, tapMapPoint)
                    // If we tapped in an arcade machine's range, display some basic info
                    if distanceFromCircleCenter <= circle.radius {
                        let annot = overlay as MKAnnotation
                        self.mapView.selectAnnotation(annot, animated: true)
                        break
                    }
                }
            }
        }
    }
    
    func getPlacemarkFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil) {print("reverse geodcode fail: \(error!.localizedDescription)")}
                let pm = placemarks! as [CLPlacemark]
                print(pm)
        })
    }
    
    // MapView Delegate
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        // This code might help later
        /*if self.selectAgain  {
        for overlay in self.mapView.overlays{
        if (overlay.isKindOfClass(MKCircle)) {
        if self.mapView.viewForAnnotation(overlay) == view {
        self.selectAgain = false
        self.mapView.selectAnnotation(overlay, animated: false)
        
        }
        }
        }
        }*/
    }
    
   /* func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let identifier = "ArcadeMachine"
        
        if ((annotation as? ArcadeMachineMkCircle) != nil) {
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
                
            }
            return annotationView
        }
        return nil
    }*/
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ArcadeMachineProfile") as! ArcadeMachineProfileViewController
        vc.arcadeMachine = (view.annotation as! ArcadeMachineMkCircle).machine as ArcadeMachine!
        self.showViewController(vc, sender: self)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? ArcadeMachineMkCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.alpha = 0.5
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
    
    // CLL Location Delegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
        NSOperationQueue().addOperationWithBlock({
            
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
            
        })
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            
            return clusterView
            
        } else {
            
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            
            if #available(iOS 9.0, *) {
                pinView!.pinTintColor = UIColor.greenColor()
            } else {
                // Fallback on earlier versions
            }
            
            return pinView
        }
        
    }
    
}


