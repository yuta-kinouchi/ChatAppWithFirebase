//
//  ChatListViewController.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/05/27.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Nuke


class ChatListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    private var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    @IBOutlet var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        confirmLoggedInUser()
        fetchLoginUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchChatroomsInfoFromFirestore()
    }
    
    private func fetchChatroomsInfoFromFirestore() {
        Firestore.firestore().collection("chatRooms").getDocuments { snapshots, err in
            if let err = err {
                print("Chatrooms情報の取得に失敗しました\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let chatroom = ChatRoom(dic: dic)
                guard let uid = Auth.auth().currentUser?.uid else { return }
                chatroom.members.forEach { (memberUid) in
                    if memberUid != uid {
                        Firestore.firestore().collection("users").document(memberUid).getDocument { (snapshot,err) in
                            if let err = err {
                                print("ユーザー情報の取得に失敗しました\(err)")
                                return
                            }
                            
                            guard let dic = snapshot?.data() else { return }
                            let user = User(dic: dic)
                            user.uid = snapshot?.documentID
                            
                            chatroom.partnerUser = user
                            self.chatrooms.append(chatroom)
                            self.chatListTableView.reloadData()
            //                print(self.chatrooms.count)
            //                print("dic: ",dic)
                        }
                    }
                }

            })
        }
    }
    
    private func setUpViews() {
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "と〜く"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
    }
    
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController" ) as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            
            self.present(signUpViewController, animated: true, completion:  nil)
        }
    }
    
    // 新規チャット開始ボタンをタップした時の動き
    @objc private func tappedNavRightBarButton() {
        // どこのストーリーボードに接続するのか
        let storyboard = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewController = storyboard.instantiateViewController(withIdentifier: "UserListViewController")
        // ここの行がない時，ナビゲーションバーが表示されない
        let nav = UINavigationController(rootViewController: userListViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)

    }

    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました\(err)")
                return
            }
            
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            // オプショナル型は中身が入っているか確認してください
            let user = User(dic: dic)
            self.user = user
        }
    }
    
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }
    
    // タップした時の反応
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController")
        navigationController?.pushViewController(chatRoomViewController, animated: true)
        
    }
    
    
}

class ChatListTableViewCell: UITableViewCell {
    
//    var user: User? {
//        didSet {
//            if let user = user {
//                partnerLabel.text = user.username
//                //            userImageView.image = user?.profileImageUrl
//                dateLabel.text = dateFormatterForDatelLabel(date: user.createdAt.dateValue())
//                latestMessageLabel.text = user.email
//            }
//        }
//    }
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                partnerLabel.text = chatroom.partnerUser?.username
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: userImageView)
                
                dateLabel.text = dateFormatterForDateLabel(date: chatroom.createdAt.dateValue())
            }
        }
    }
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var latestMessageLabel: UILabel!
    @IBOutlet var partnerLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 35
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formattter = DateFormatter()
        formattter.dateStyle = .full
        formattter.timeStyle = .none
        formattter.locale = Locale(identifier: "ja_JP")
        return formattter.string(from: date)
    }
}

