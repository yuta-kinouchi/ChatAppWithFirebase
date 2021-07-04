//
//  UserListViewController.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/05/29.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Nuke
import PKHUD

class UserListViewController: UIViewController {
    @IBOutlet var userListTableView: UITableView!
    @IBOutlet var startChatButton: UIButton!
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        startChatButton.layer.cornerRadius = 15
        startChatButton.isEnabled = false
        startChatButton.addTarget(self, action: #selector(tappedStartChatButton), for: .touchUpInside)
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        fetchUserInfoFromFirestore()
    }
    
    @objc func tappedStartChatButton() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        HUD.show(.progress)
        let docRef = ConnectFirebase().getChatRoomDocmentRefWithUid(uid: uid, partnerUid: partnerUid)
        docRef.getDocuments() { (document, err) in
            if document?.isEmpty == true {
                let members = [uid, partnerUid]
                let docData = [
                    "members": members,
                    "latestMessageId": "",
                    "createdAt": Timestamp()
                ] as [String : Any]
                
                let colRef = ConnectFirebase().getChatRoomsColectionRef()
                    colRef.addDocument(data: docData) { (err) in
                    if let err = err {
                        print("ChatRoom情報の保存に失敗しました\(err)")
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                    print("ChatRoom情報の保存に成功しました")
                    HUD.hide()
                }
            }else{
                let dialog = UIAlertController(title: "", message: "すでにチャットルームが存在します",  preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
                HUD.hide()
            }
        }
    }
    
    private func fetchUserInfoFromFirestore() {
        let colRef = ConnectFirebase().getUserColectionRef()
        colRef.getDocuments { snapshots, err in
            if let err = err {
                print("ユーザー情報の取得に失敗しました\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID
                guard let uid = Auth.auth().currentUser?.uid else { return }
                if uid == snapshot.documentID {
                    return
                }
                self.users.append(user)
                self.userListTableView.reloadData()
            })
        }
    }
}

extension UserListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatButton.isEnabled = true
        let user = users[indexPath.row]
        self.selectedUser = user
    }
}

class UserListTableViewCell: UITableViewCell {
    var user: User? {
        didSet{
            usernameLabel.text = user?.username
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userImageView)
            }
        }
    }
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 32.5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
