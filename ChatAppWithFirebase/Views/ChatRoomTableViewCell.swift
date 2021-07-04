//
//  ChatRoomTableViewCell.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/05/27.
//

import UIKit
import FirebaseAuth
import Nuke

class ChatRoomTableViewCell: UITableViewCell {
    var message: Message? {
        didSet {
            // Nothing to do
        }
    }
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var partnerMessageTextView: UITextView!
    @IBOutlet var myMessageTextView: UITextView!
    @IBOutlet var partnerDateLabel: UILabel!
    @IBOutlet var myDateLabel: UILabel!
    @IBOutlet var messageTextViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var myMessageTextViewWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30
        partnerMessageTextView.layer.cornerRadius = 15
        partnerMessageTextView.textColor = UIColor.black
        myMessageTextView.layer.cornerRadius = 15
        myMessageTextView.textColor = UIColor.black
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWitchUserMessage()
    }
    
    private func checkWitchUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == message?.uid {
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            userImageView.isHidden = true
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false
            if let message = message {
                myMessageTextView.text = message.message
                let width = estimateFlameForTextView(text: message.message).width + 20
                myMessageTextViewWidthConstraint.constant = width
                myDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
            }
        } else {
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            userImageView.isHidden = false
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true
            if let urlString = message?.partnerUser?.profileImageUrl,let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: userImageView)
            }
            if let message = message {
                partnerMessageTextView.text = message.message
                let width = estimateFlameForTextView(text: message.message).width + 20
                messageTextViewWidthConstraint.constant = width
                partnerDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
            }
        }
    }
    
    // メッセージの量に応じて吹き出しのサイズを変更する関数
    private func estimateFlameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)] , context: nil)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formattter = DateFormatter()
        formattter.dateStyle = .short
        formattter.timeStyle = .short
        formattter.locale = Locale(identifier: "ja_JP")
        return formattter.string(from: date)
    }
}
