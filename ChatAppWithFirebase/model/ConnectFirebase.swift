//
//  Filebase.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/06/28.
//
//

//import Firebase
//import FirebaseFirestore
//import FirebaseAuth
//
//class ConnectFirebase {
//    
//    func fetchChatrooms(chatrooms: Array<Any>,chatListTableView: ListenerRegistration?) {
//        Firestore.firestore().collection("chatRooms")
//            .addSnapshotListener { (snapshots , err)  in
//                if let err = err {
//                    print("Chatrooms情報の取得に失敗しました\(err)")
//                    return
//                }
//                snapshots?.documentChanges.forEach({ DocumentChange in
//                    switch DocumentChange.type {
//                    // データベースに追加された情報だけを取ってくる
//                    case .added:
//                        let dic = DocumentChange.document.data()
//                        let chatroom = ChatRoom(dic: dic)
//                        chatroom.documentId = DocumentChange.document.documentID
//                        guard let uid = Auth.auth().currentUser?.uid else { return }
//                        let isContain = chatroom.members.contains(uid)
//                        if !isContain { return }
//                        chatroom.members.forEach { (memberUid) in
//                            if memberUid != uid {
//                                Firestore.firestore().collection("users").document(memberUid).getDocument { (userSnapshot,err) in
//                                    if let err = err {
//                                        print("ユーザー情報の取得に失敗しました\(err)")
//                                        return
//                                    }
//                                    guard let dic = userSnapshot?.data() else { return }
//                                    let user = User(dic: dic)
//                                    user.uid = DocumentChange.document.documentID
//                                    chatroom.partnerUser  = user
//                                    let latestMessageId = chatroom.latestMessageId
//                                    if latestMessageId == "" {
//                                        chatrooms.append(chatroom)
//                                        chatListTableView.reloadData()
//                                        return
//                                    }
//                                    Firestore.firestore().collection("chatRooms").document(chatroom.documentId ?? "").collection("messages").document(latestMessageId).getDocument {(messageSnapshot,err) in
//                                        if let err = err {
//                                            print("最新情報の取得に失敗しました\(err)")
//                                            return
//                                        }
//                                        guard let dic = messageSnapshot?.data() else { return }
//                                        let message = Message(dic: dic)
//                                        chatroom.latestMessage = message
//                                        
//                                        chatrooms.append(chatroom)
//                                        chatListTableView.reloadData()
//                                    }
//                                }
//                            }
//                        }
//                    case .modified , .removed:
//                        print("nothing to do")
//                    }
//                }
//            )
//        }
//    }
//}
