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
    let chatChannelId: String
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let locationName : String?

    
    init(userId: String, chatChannelId: String, latitude: Double, longitude: Double) {
        self.userId = userId
        self.chatChannelId = chatChannelId
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = "aloha"
        self.locationName = "ssss"
        
        super.init()
    }
    
    var subtitle: String? {
        return userId
    }
}
