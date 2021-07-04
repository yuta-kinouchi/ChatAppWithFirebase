//
//  ChatRoomViewController.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/05/27.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ChatRoomViewController: UIViewController {
    private let cellId = "cellId"
    private var messages = [Message]()
    private let accessoryHeight: CGFloat = 100
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    var chatroom: ChatRoom?
    var user: User?
    // 送信部分のインスタンスを作成
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        // chatinputaccessoryviewで指定したdelegateをここで受け取る
        view.delegate = self
        return view
    }()
    
    @IBOutlet var chatRoomTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupChatRoomTableView()
        fetchMessage()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupChatRoomTableView() {
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        // スクロールした時にキーボードを下げる
        chatRoomTableView.keyboardDismissMode = .interactive
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        //下のテキストが見切れた時に，表示させることができる
        chatRoomTableView.contentInset = .init(top: 80, left: 0, bottom: 0, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 80, left: 0, bottom: 0, right: 0)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            if keyboardFrame.height <= accessoryHeight  { return }
            let top = keyboardFrame.height - safeAreaBottom
            var moveY = -(top - chatRoomTableView.contentOffset.y )
            if chatRoomTableView.contentOffset.y != -60 { moveY += 60 }
            let contentINset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            chatRoomTableView.contentInset = contentINset
            chatRoomTableView.scrollIndicatorInsets = contentINset
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    
    @objc func keyboardWillHide() {
        chatRoomTableView.contentInset = .init(top: 80, left: 0, bottom: 0, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 80, left: 0, bottom: 0, right: 0)
    }
    
    // キーボード表示を行うときにキーボードに合わせてスライドする
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessage() {
        guard let chatroomDocId = chatroom?.documentId else { return }
        let docRef = ConnectFirebase().getMessagesColectionRef(chatroomDocId: chatroomDocId)
            docRef.addSnapshotListener { (snapshots,err) in
                if let err = err {
                    print("メッセージ情報の取得に失敗しました\(err)")
                    return
                }
                snapshots?.documentChanges.forEach({ DocumentChange in
                    switch DocumentChange.type {
                    case .added:
                        let dic = DocumentChange.document.data()
                        let message = Message(dic: dic)
                        message.partnerUser = self.chatroom?.partnerUser
                        self.messages.append(message)
                        // 日付順に並び替える
                        self.messages.sort { (m1,m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                        }
                        self.chatRoomTableView.reloadData()
                    case .modified, .removed:
                        print("nothing to do")
                    }
                }
                )
            }
    }
}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    // 送信ボタンをタップした時の挙動
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    
    private func addMessageToFirestore(text: String) {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()
        let messageId = randomString(length: 20)
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String: Any]
        let docRef = ConnectFirebase().getMessageDocumentWithMessageId(chatroomDocId: chatroomDocId, messageId: messageId)
            docRef.setData(docData) { (err) in
                if let err = err {
                    print("メッセージ情報の保存に失敗しました\(err)")
                    return
                }
                let latestMessageDate = [
                    "latestMessageId": messageId
                ]
                let docRef = ConnectFirebase().getChatRoomDocumentRefWithChatRoomDocId(chatroomDocId: chatroomDocId)
                    docRef.updateData(latestMessageDate) { (err) in
                    if let err = err {
                        print("最新のメッセージの保存に失敗しました\(err)")
                        return
                    }
                }
            }
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath ) as! ChatRoomTableViewCell
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        cell.message = messages[indexPath.row]
        return cell
    }
}
