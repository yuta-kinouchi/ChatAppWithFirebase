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

class UserListViewController: UIViewController {
    @IBOutlet var userListTableView: UITableView!
    @IBOutlet var startChatButton: UIButton!
    
    
    private let cellId = "cellId"
    private var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.delegate = self
        userListTableView.dataSource = self
        startChatButton.layer.cornerRadius = 15
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        fetchUserInfoFromFirestore()
    }
    
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { snapshots, err in
            if let err = err {
                print("ユーザー情報の取得に失敗しました\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                
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
        userImageView.layer.cornerRadius = 25
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
