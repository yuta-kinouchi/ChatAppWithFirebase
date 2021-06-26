//
//  ChatInputAccessoruView.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/05/27.
//

import UIKit

// delegateを使うためにプロトコルを作った
protocol ChatInputAccessoryViewDelegate: class {
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView {
    @IBOutlet var chatTextView: UITextView!
    @IBOutlet var sendButton: UIButton!
    // ボタンが押された時のアクション
    @IBAction func tappedSendButton(_ sender: Any) {
        // 打ち込まれたテキストをchatroomviewcontrollerで使うためにdelegateを．．．
        guard let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
    }
    
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight
    }
    
    private func setupViews() {
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 233, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        // 初期状態の表示
        chatTextView.text = ""
        // delegateって何？
        chatTextView.delegate = self
        if (UITraitCollection.current.userInterfaceStyle == .dark) {
            chatTextView.textColor = UIColor.black
            sendButton.backgroundColor = UIColor.black
        }
        
    }
    
    func removeText() {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // これなにしてるんだ
    private func nibInit() {
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    

 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ChatInputAccessoryView: UITextViewDelegate {
    
    // テキストが変更するたびに呼び出される関数
    func textViewDidChange(_ textView: UITextView) {
        // テキストがなければボタンは押せない
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
}
