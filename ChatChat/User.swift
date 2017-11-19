//
//  UserChannel.swift
//  ChatChat
//
//  Created by Carlos Lee on 2017-11-19.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//
import MapKit

internal class User: NSObject, MKAnnotation {
    let userId: String
    let chatChannelId: String
    let coordinate: CLLocationCoordinate2D
    
    init(userId: String, chatChannelId: String, latitude: Double, longitude: Double) {
        self.userId = userId
        self.chatChannelId = chatChannelId
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        super.init()
    }
    
    var subtitle: String? {
        return userId
    }
}
