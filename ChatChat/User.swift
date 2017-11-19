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

internal class User: NSObject, MKAnnotation {
    let userId: String
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let locationName : String?

    
    init(userId: String, name: String, latitude: Double, longitude: Double) {
        self.userId = userId
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = name
        self.locationName = userId
        
        super.init()
    }
    
    var subtitle: String? {
        return String(coordinate.latitude) + ", " + String(coordinate.longitude)
    }
}
