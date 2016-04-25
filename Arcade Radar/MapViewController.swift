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
    
    @IBOutlet var mapView: MKMapView!
    var selectAgain = false
    var isInSelectionMode = false
    let locationManager = CLLocationManager()
    
    
    override func viewDidAppear(animated: Bool) {
        //self.refresh()
        //self.cancelAddNewTurf()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Location manager
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            print("STARTING")
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapMap:")
        self.mapView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "didPanMap:")
        panGesture.delegate = self
        self.mapView.addGestureRecognizer(panGesture)
        
        // Nav SetUp
        let navigationBar = navigationController!.navigationBar
        navigationBar.tintColor = Colors.colorWithHexString("#00B0FF")
        
        navigationItem.leftBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh"), MKUserTrackingBarButtonItem(mapView: self.mapView)]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewTurf")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func refresh() {
        if abs(self.mapView.region.span.latitudeDelta) < 0.15 && abs(self.mapView.region.span.longitudeDelta) < 0.13 {
            let nePoint = CGPointMake(self.mapView.bounds.origin.x + mapView.bounds.size.width + 100, mapView.bounds.origin.y - 100);
            let swPoint = CGPointMake((self.mapView.bounds.origin.x - 100), (mapView.bounds.origin.y + mapView.bounds.size.height) + 100);
            
            //Then transform those point into lat,lng values
            let neCoord = self.mapView.convertPoint(nePoint, toCoordinateFromView: self.mapView)
            let swCoord = self.mapView.convertPoint(swPoint, toCoordinateFromView: self.mapView)
            
            let swBounds = PFGeoPoint(latitude:swCoord.latitude, longitude:swCoord.longitude)
            let neBounds = PFGeoPoint(latitude:neCoord.latitude, longitude:neCoord.longitude)
            let query = PFQuery(className:"Territories")
            query.whereKey("location", withinGeoBoxFromSouthwest:swBounds, toNortheast:neBounds)
            query.findObjectsInBackgroundWithBlock {  (objects: [PFObject]?, error: NSError?) -> Void in
                if objects?.count > 0 {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.removeOverlays(self.mapView.overlays)
                    for territoryRaw in objects! {
                        let territory = Territory.territoryForPFObject(territoryRaw)
                        self.mapView.addAnnotation(territory)
                        self.mapView.addOverlay(territory)
                    }
                    if self.isInSelectionMode {
                        self.addNewTurf()
                    }
                }
            }
        }
    }
    
    func addNewTurf() {
        if (PFUser.currentUser()!["turfs"] as! Int) < PFUser.currentUser()!["turfLimit"] as! Int {
            let selectionTurf = Territory(centerCoordinate: CLLocationCoordinate2D(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!), radius: CLLocationDistance(3218.68))
            self.isInSelectionMode = true
            selectionTurf.title = "$3L3CTION TURF #TITLE"
            selectionTurf.color = UIColor.greenColor()
            self.mapView.addOverlay(selectionTurf)
            for overlay in self.mapView.overlays {
                if (overlay as! Territory).owner == PFUser.currentUser() {
                    print("EH")
                    let selectionTurf1 = Territory(centerCoordinate: CLLocationCoordinate2D(latitude: overlay.coordinate.latitude, longitude: overlay.coordinate.longitude), radius: CLLocationDistance(1609.34))
                    selectionTurf1.title = "$3L3CTION TURF #TITLE"
                    selectionTurf1.color = UIColor.greenColor()
                    self.mapView.addOverlay(selectionTurf1)
                }
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelAddNewTurf")
        }else {
            let alert = UIAlertController(title: "Oh No!", message: "You have already reached the maximum amount of territory for your level! You can buy upgrades on your current territory!", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func cancelAddNewTurf() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewTurf")
        self.isInSelectionMode = false
        for overlay in self.mapView.overlays{
            if (overlay.isKindOfClass(Territory)) {
                if overlay.title! == "$3L3CTION TURF #TITLE" {
                    self.mapView.removeAnnotation(overlay)
                    self.mapView.removeOverlay(overlay)
                }
            }
        }
    }*/
    
    func didPanMap(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .Ended {
            //refresh()
            
            print("THE END")
        }
    }
    
    func didTapMap(gestureRecognizer: UIGestureRecognizer) {
        
       /* if gestureRecognizer.state == .Ended { // only register when a tap has ended
            let tapPoint: CGPoint = gestureRecognizer.locationInView(self.mapView)
            let tapCoordinate = self.mapView.convertPoint(tapPoint, toCoordinateFromView: self.mapView)
            let tapMapPoint = MKMapPointForCoordinate(tapCoordinate)
            for overlay in self.mapView.overlays{
                if (overlay.isKindOfClass(MKCircle))
                {
                    let circle = overlay as! MKCircle
                    
                    let circleCenterMapPoint = MKMapPointForCoordinate(circle.coordinate)
                    
                    let distanceFromCircleCenter = MKMetersBetweenMapPoints(circleCenterMapPoint, tapMapPoint)
                    if distanceFromCircleCenter <= circle.radius {
                        let annot = overlay as MKAnnotation
                        // We are only looking for green circles
                        if isInSelectionMode {
                            if annot.title! == "$3L3CTION TURF #TITLE" {
                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MakeANewTerritory") as! MakeANewTerritoryViewController
                                vc.lat = (tapCoordinate.latitude) as Double
                                vc.long = (tapCoordinate .longitude)as Double
                                self.showViewController(vc, sender: self)
                                break
                            }
                        }else {
                            self.mapView.selectAnnotation(annot, animated: true)
                            self.selectAgain = true
                            NSLog("tapped in circle")
                            break
                        }
                    }
                }
            }
        }*/
    }
    
    // MapView Delegate
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if self.selectAgain  {
            for overlay in self.mapView.overlays{
                if (overlay.isKindOfClass(MKCircle)) {
                    if self.mapView.viewForAnnotation(overlay) == view {
                        self.selectAgain = false
                        self.mapView.selectAnnotation(overlay, animated: false)
                        
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // 1
        let identifier = "Territory"
        if ((annotation as? ArcadeMachine) != nil) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
            
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
                
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TerritoryProfile") as! TerritoryProfileViewController
        //vc.territory = view.annotation as! Territory
        //self.showViewController(vc, sender: self)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? ArcadeMachine {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            //circleRenderer.
            circleRenderer.alpha = 0.5
            //circleRenderer.fillColor = overlay.color
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

