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
    
    var arcadeMachineWhereClauseExtension = ""
    var backendless = Backendless()
    var hasBackButton = false
    var machines: NSMutableArray = NSMutableArray()
    let clusteringManager = FBClusteringManager()
    
    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    var startingGeoPoint:GeoPoint?
    
    override func viewDidAppear(animated: Bool) {
        self.refresh()
        if self.startingGeoPoint != nil {
            let latitude = self.startingGeoPoint?.latitude
            let longitude = self.startingGeoPoint?.longitude
            let latDelta:CLLocationDegrees = 0.03
            let lonDelta:CLLocationDegrees = 0.03
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            mapView.setRegion(region, animated: true)
        }
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
        if hasBackButton {
            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItems = nil
        }else {
            navigationItem.leftBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh"), MKUserTrackingBarButtonItem(mapView: self.mapView)]
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewArcade")
        }
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
    
    func addNewArcade() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("NewArcade") as! NewArcadeViewController
        let nav = UINavigationController(rootViewController: vc)
        self.presentViewController(nav, animated: true, completion: nil)
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
            queryOptions.pageSize = 100
            //queryOptions.so
            let query = BackendlessDataQuery()
            query.queryOptions = queryOptions
            if self.arcadeMachineWhereClauseExtension.isEmpty { // if the map is searching for arcades
                query.whereClause = "geoPoint.latitude < \(nwCoord.latitude) AND geoPoint.latitude > \(seCoord.latitude) AND geoPoint.longitude > \(nwCoord.longitude) AND geoPoint.longitude < \(seCoord.longitude)"
                
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0), { () -> Void in
                    Types.tryblock({ () -> Void in
                        let arcadesSearched: BackendlessCollection! = self.backendless.data.of(Arcade.ofClass()).find(query)
                        let currentPage = arcadesSearched.getCurrentPage()
                        for arcade in currentPage {
                            let overlay = ArcadeMkCircle(centerCoordinate: CLLocationCoordinate2D(latitude: ((arcade.geoPoint as GeoPoint).latitude as Double), longitude: ((arcade.geoPoint as GeoPoint).longitude as Double)), radius: 20)
                            overlay.setArcadeToDisplay(arcade as! Arcade)
                            var isAlreadyThere = false
                            if (self.clusteringManager.allAnnotations() as! [ArcadeMkCircle]).contains({ (arcade1: ArcadeMkCircle) -> Bool in
                                return arcade1.arcade.geoPoint?.latitude == overlay.arcade.geoPoint?.latitude && arcade1.arcade.geoPoint?.longitude == overlay.arcade.geoPoint?.longitude && arcade1.arcade.name == overlay.arcade.name
                            }) {
                                isAlreadyThere = true
                            }
                            
                            if !isAlreadyThere {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.clusteringManager.addAnnotations([overlay])
                                    NSOperationQueue().addOperationWithBlock({
                                        
                                        let mapBoundsWidth = Double(self.mapView.bounds.size.width)
                                        let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
                                        let scale:Double = mapBoundsWidth / mapRectWidth
                                        let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
                                        print(annotationArray)
                                        self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
                                    })
                                })
                            }
                        }
                        }, catchblock: { (exception) -> Void in
                            print(exception)
                    })
                })
            }else { // if the map is searching for arcade machines
                query.whereClause = "geoPoint.latitude < \(nwCoord.latitude) AND geoPoint.latitude > \(seCoord.latitude) AND geoPoint.longitude > \(nwCoord.longitude) AND geoPoint.longitude < \(seCoord.longitude) \(self.arcadeMachineWhereClauseExtension)"
                print(query.whereClause)
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0), { () -> Void in
                    Types.tryblock({ () -> Void in
                        let arcadeMachinesSearched: BackendlessCollection! = self.backendless.data.of(ArcadeMachine.ofClass()).find(query)
                        let currentPage = arcadeMachinesSearched.getCurrentPage()
                        for arcadeMachine in currentPage {
                            let overlay = ArcadeMachineMkCircle(centerCoordinate: CLLocationCoordinate2D(latitude: ((arcadeMachine.geoPoint as GeoPoint).latitude as Double), longitude: ((arcadeMachine.geoPoint as GeoPoint).longitude as Double)), radius: 20)
                            overlay.setArcadeMachine(arcadeMachine as! ArcadeMachine)
                            var isAlreadyThere = false
                            if (self.clusteringManager.allAnnotations() as! [ArcadeMachineMkCircle]).contains({ (arcadeMachine1: ArcadeMachineMkCircle) -> Bool in
                                return arcadeMachine1.machine!.geoPoint?.latitude == overlay.machine!.geoPoint?.latitude && arcadeMachine1.machine!.geoPoint?.longitude == overlay.machine!.geoPoint?.longitude && arcadeMachine1.machine!.name == overlay.machine!.name
                                
                            }) {
                                isAlreadyThere = true
                            }
                            
                            if !isAlreadyThere {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    
                                    self.clusteringManager.addAnnotations([overlay])
                                    NSOperationQueue().addOperationWithBlock({
                                        let mapBoundsWidth = Double(self.mapView.bounds.size.width)
                                        
                                        let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
                                        
                                        let scale:Double = mapBoundsWidth / mapRectWidth
                                        
                                        let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
                                        print(annotationArray)
                                        self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
                                        
                                    })
                                    
                                })
                            }
                        }
                        
                        }, catchblock: { (exception) -> Void in
                            print(exception)
                    })
                })
            }
        }
    }
    
    func didPanMap(gestureRecognizer: UIGestureRecognizer) {
        // If the tap is ending (prevents double reload)
        if gestureRecognizer.state == .Ended {
            //refresh()
        }
    }
    
    func didTapMap(gestureRecognizer: UIGestureRecognizer) {
        // Only register when a tap has ended
        /* if gestureRecognizer.state == .Ended {
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
        }*/
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
        if (view.tag == 0) { // is a cluster object
            if !self.arcadeMachineWhereClauseExtension.isEmpty {
                let vc = ArcadeMachinesTableViewController()
                vc.machines = ((view.annotation as! FBAnnotationCluster).annotations as! [ArcadeMachineMkCircle]).map({ $0.machine!})
                vc.title = (view.annotation?.title)!
                self.showViewController(vc, sender: self)
            }else {
                let vc = ArcadesTableViewController()
                vc.arcades = ((view.annotation as! FBAnnotationCluster).annotations as! [ArcadeMkCircle]).map({ $0.arcade})
                vc.title = (view.annotation?.title)!
                self.showViewController(vc, sender: self)
            }
        }else if (view.tag == 1) {
            if let _ = view.annotation as? ArcadeMachineMkCircle {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ArcadeMachineProfile") as! ArcadeMachineProfileViewController
                vc.arcadeMachine = (view.annotation as! ArcadeMachineMkCircle).machine as ArcadeMachine!
                self.showViewController(vc, sender: self)
            }else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ArcadeProfile") as! ArcadeProfileViewController
                vc.arcade = (view.annotation as! ArcadeMkCircle).arcade as Arcade!
                self.showViewController(vc, sender: self)
            }
        }
    }
    
    /*func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if let overlay = overlay as? ArcadeMachineMkCircle {
    let circleRenderer = MKCircleRenderer(circle: overlay)
    circleRenderer.alpha = 0.5
    return circleRenderer
    }
    return MKOverlayRenderer()
    }*/
    
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
        self.refresh()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            
            reuseId = "Cluster"
            (annotation as! FBAnnotationCluster).setTitleOfCluster("\(((annotation as! FBAnnotationCluster).annotations as! [ArcadeMkCircle]).count) Arcades")
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            clusterView!.canShowCallout = true
            clusterView?.tag = 0
            
            let btn = UIButton(type: .DetailDisclosure)
            clusterView!.rightCalloutAccessoryView = btn
            //clusterView!.title
            return clusterView
            
        } else if annotation.isKindOfClass(MKUserLocation){
            return nil
        } else {
            
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as MKAnnotationView?
            if (pinView == nil) {
                pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            
            pinView?.image = UIImage(named: "cabinetFacing.png")
            pinView?.frame.size = CGSize(width: 45, height: 45)
            pinView?.canShowCallout = true
            
            let btn = UIButton(type: .DetailDisclosure)
            pinView?.rightCalloutAccessoryView = btn
            pinView?.tag = 1
            return pinView
        }
    }
}