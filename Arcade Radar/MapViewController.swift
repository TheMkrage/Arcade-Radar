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
        
        /*let machine = ArcadeMachine()
        machine.name = "DDR X"
        
        machine.geoPoint = GeoPoint.geoPoint(
            GEO_POINT(latitude: 33.700, longitude: -118.02)
            ) as? GeoPoint
        backendless.persistenceService.of(ArcadeMachine.ofClass()).save(machine)*/
        
        /* backendless.geoService.savePoint(
        houstonTX,
        response: { (var point : GeoPoint!) -> () in
        print("ASYNC: geo point saved. Object ID - \(point.objectId)")
        },
        error: { (var fault : Fault!) -> () in
        print("Server reported an error: \(fault)")
        }
        )*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refresh() {
        if abs(self.mapView.region.span.latitudeDelta) < 0.4 && abs(self.mapView.region.span.longitudeDelta) < 0.38 {
            let nwPoint = CGPointMake(self.mapView.bounds.origin.x - 100, mapView.bounds.origin.y - 100);
            let sePoint = CGPointMake((self.mapView.bounds.origin.x + self.mapView.bounds.size.width + 100), (mapView.bounds.origin.y + mapView.bounds.size.height) + 100);
            // Transform points into lat,lng values
            let nwCoord = self.mapView.convertPoint(nwPoint, toCoordinateFromView: self.mapView)
            let seCoord = self.mapView.convertPoint(sePoint, toCoordinateFromView: self.mapView)
            
            print(nwCoord)
            print(seCoord)
            // Search backendless for machines in the view
            //var query2 = BackendlessDataQuery
            let queryOptions = QueryOptions()
            queryOptions.addRelated("geoPoint")
            //queryOptions.so
            let query = BackendlessDataQuery()
            query.queryOptions = queryOptions
            query.whereClause = "geoPoint.latitude < \(nwCoord.latitude) AND geoPoint.latitude > \(seCoord.latitude) AND geoPoint.longitude > \(nwCoord.longitude) AND geoPoint.longitude < \(seCoord.longitude)"
            backendless.persistenceService.of(ArcadeMachine.ofClass()).find(
                query,
                response: { ( machinesSearched : BackendlessCollection!) -> () in
                    let currentPage = machinesSearched.getCurrentPage()
                    print("Loaded \(currentPage.count) machine objects")
                    print("Total restaurants in the Backendless starage - \(machinesSearched.totalObjects)")
                    
                    for machine in currentPage {
                        print("Restaurant name = \(machine.name)")
                        print(machine.geoPoint)
                        let overlay = ArcadeMachineMkCircle(centerCoordinate: CLLocationCoordinate2D(latitude: ((machine.geoPoint as GeoPoint).latitude as Double), longitude: ((machine.geoPoint as GeoPoint).longitude as Double)), radius: 20)
                        overlay.setArcadeMachine(machine as! ArcadeMachine)
                        var isAlreadyThere = false
                        for current in self.mapView.overlays as! [ArcadeMachineMkCircle] {
                            if current.machine?.geoPoint?.latitude == overlay.machine?.geoPoint?.latitude {
                                if current.machine?.geoPoint?.longitude == overlay.machine?.geoPoint?.longitude {
                                    if current.machine?.name == overlay.machine?.name {
                                        isAlreadyThere = true
                                    }
                                }
                            }
                        }
                        if !isAlreadyThere {
                            self.mapView.addOverlay(overlay)
                            self.mapView.addAnnotation(overlay)
                        }
                    }
                },
                error: { ( fault : Fault!) -> () in
                    print("Server reported an error: \(fault)")
                }
            )
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
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let identifier = "ArcadeMachine"
        print("HOWDYY")
        if ((annotation as? ArcadeMachineMkCircle) != nil) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
                print("INIT!")
            
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
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

