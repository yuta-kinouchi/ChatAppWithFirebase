//
//  Filebase.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/06/28.
//
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

class ConnectFirebase {
    
    func getChatRoomsColectionRef() -> CollectionReference{
        let ref = Firestore.firestore().collection("chatRooms")
        return ref
    }
    
    func getChatRoomDocumentRefWithUid(uid: String) -> DocumentReference{
        let ref = Firestore.firestore().collection("users").document(uid)
        return ref
    }
    
    func getChatRoomDocmentRefWithUid(uid : String, partnerUid :String) -> Query{
        let ref = Firestore.firestore().collection("chatRooms").whereField("members", arrayContains: [uid, partnerUid])
        return ref
    }
    
    func getChatRoomDocumentRefWithChatRoomDocId(chatroomDocId: String) -> DocumentReference{
        let ref = Firestore.firestore().collection("chatRooms").document(chatroomDocId)
        return ref
    }
    
    func getUserColectionRef() -> CollectionReference{
        let ref = Firestore.firestore().collection("users")
        return ref
    }
    
    func getUserDocumentRefWithUid(memberUid: String) -> DocumentReference {
        let ref = Firestore.firestore().collection("users").document(memberUid)
        return ref
    }

    func getMessagesColectionRef(chatroomDocId: String) -> CollectionReference{
        let ref = Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages")
        return ref
    }
    
    func getMessagesDocumentWithLatestMessageId(chatroom: ChatRoom, latestMessageId: String) -> DocumentReference {
        let ref = Firestore.firestore().collection("chatRooms").document(chatroom.documentId ?? "").collection("messages").document(latestMessageId)
        return ref
    }
    
    func getMessageDocumentWithMessageId(chatroomDocId: String,messageId: String) -> DocumentReference{
        let ref = Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId)
        return ref
    }
    
    func getCurrentUser() -> String?{
        let uid = Auth.auth().currentUser?.uid
        return uid
    }
}
