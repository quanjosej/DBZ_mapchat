//
//  MapViewController.swift
//  ChatChat
//
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class MapViewController: UIViewController, CLLocationManagerDelegate{
    
    private lazy var DBZUsersRef: DatabaseReference = Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!)
    private var dbzUsersRefHandle: DatabaseHandle?
    private var connectedUsers: [User] = []

    
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
            
            //Set curr user connection statues
            DBZUsersRef.child("connected_status").onDisconnectSetValue(false)
            DBZUsersRef.child("connected_status").setValue(true)
            
            loadOnlineDbzUsers()
            displayUsersOnMap()
            observeDbzUsers()
            
        }
        
    }
    
    private func loadOnlineDbzUsers() {
        
        DBZUsersRef.queryEqual(toValue: "true", childKey: "connected_status").observeSingleEvent(of: .value, with: {(snap) in
            self.connectedUsers.append(User(userId: snap.key , chatChannelId: "sss", latitude: 43.654335, longitude: -79.3957 ))
        })
        
    }
    
    private func displayUsersOnMap() {
        //Clear old annotations
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        self.mapView.addAnnotations(connectedUsers)
        
    }
    
    private func observeDbzUsers() {
        dbzUsersRefHandle = Database.database().reference().child("dbz_users").observe(.childChanged, with: { (snapshot) -> Void in
            let dbzUserData = snapshot.value as! Dictionary<String, AnyObject>
            
            if let firstNegative = self.connectedUsers.index(where: { $0.userId == snapshot.key }) {
                self.connectedUsers.remove(at: firstNegative)
            }
            
            if (dbzUserData["connected_status"] as! Bool) {
                self.connectedUsers.append(User(userId: snapshot.key , chatChannelId: "sss", latitude: Double(dbzUserData["latitude"] as! String)!, longitude: Double(dbzUserData["longitude"] as! String)! ))
            }
            
            self.displayUsersOnMap()
            
        })
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.showsUserLocation = true
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
           
            //Set curr user gps location
            DBZUsersRef.child("latitude").setValue(String(describing: location.coordinate.latitude))
            DBZUsersRef.child("longitude").setValue(String(describing: location.coordinate.longitude))
            centerMapOnLocation(location: location)
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to track the Dragon Balls we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
