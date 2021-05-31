//
//  ChatRoom.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/06/01.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ChatRoom {
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    var partnerUser: User?
    
    init(dic: [String: Any ]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
