//
//  Filebase.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/06/28.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

class Firebase {
    func chatList(memberUid) ->  {
        Firestore.firestore().collection("users").document(memberUid).getDocument { (userSnapshot,err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました\(err)")
                return
            }
            guard let dic = userSnapshot?.data() else { return }
            let user = User(dic: dic)
            user.uid = documentChange.document.documentID
            chatroom.partnerUser  = user
            let latestMessageId = chatroom.latestMessageId
            if latestMessageId == "" {
                self.chatrooms.append(chatroom)
                self.chatListTableView.reloadData()
                return
            }
            Firestore.firestore().collection("chatRooms").document(chatroom.documentId ?? "").collection("messages").document(latestMessageId).getDocument {(messageSnapshot,err) in
                if let err = err {
                    print("最新情報の取得に失敗しました\(err)")
                    return
                }
                guard let dic = messageSnapshot?.data() else { return }
                let message = Message(dic: dic)
                chatroom.latestMessage = message
                
                self.chatrooms.append(chatroom)
                self.chatListTableView.reloadData()
            }
        }
    }
}
