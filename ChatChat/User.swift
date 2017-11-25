//
//  UserChannel.swift
//  ChatChat
//
//  Created by Carlos Lee on 2017-11-19.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//
import MapKit
import Contacts
import Foundation
import Firebase

internal class User: NSObject, MKAnnotation {
    let userId: String
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let locationName : String?
    let connected_status: Bool?


    
    init(userId: String, name: String, latitude: Double, longitude: Double, status: Bool? = true) {
        self.userId = userId
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = name
        self.locationName = userId
        self.connected_status = status
        
        super.init()
    }
    
    
    init(snapshot: DataSnapshot) {
        
        self.userId = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.coordinate = CLLocationCoordinate2D(latitude: Double(snapshotValue["latitude"] as! String )!, longitude: Double(snapshotValue["longitude"] as! String)!  )
        self.title = snapshotValue["name"] as! String
        self.connected_status = snapshotValue["connected_status"] as! Bool
        self.locationName = snapshot.key
    }
    
    var subtitle: String? {
        return String(coordinate.latitude) + ", " + String(coordinate.longitude)
    }
}
