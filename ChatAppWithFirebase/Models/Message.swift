//
//  Message.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/06/03.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class Message {
    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    
    init(dic: [String: Any]) {
        self.name = dic[""] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        
    }
}
