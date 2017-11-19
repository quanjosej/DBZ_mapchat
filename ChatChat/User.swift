//
//  UserChannel.swift
//  ChatChat
//
//  Created by Carlos Lee on 2017-11-19.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

internal class Users {
    let userId: String
    let chatChannelId: String
    
    init(userId: String, chatChannelId: String) {
        self.userId = userId
        self.chatChannelId = chatChannelId
    }
}
