//
//  User.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/05/28.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
//スーパークラスなし
class User {
    let email: String
    let username: String
    let createdAt: Timestamp
    let profileImageUrl: String
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }
}
