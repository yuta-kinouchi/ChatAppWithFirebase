//
//  ChatRoomTableViewCell.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/05/27.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            if let message = message {
                messageTextView.text = message.message
                let width = estimateFlameForTextView(text: message.message).width + 20
                messageTextViewWidthConstraint.constant = width
                dateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
//                userImageView
            }
        }
    }
    
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var messageTextViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30
        messageTextView.layer.cornerRadius = 15
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func estimateFlameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)] , context: nil)
    }
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formattter = DateFormatter()
        formattter.dateStyle = .none
        formattter.timeStyle = .short
        formattter.locale = Locale(identifier: "ja_JP")
        return formattter.string(from: date)
    }
}
