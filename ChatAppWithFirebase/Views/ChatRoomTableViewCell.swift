//
//  ChatRoomTableViewCell.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/05/27.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    var messageText: String? {
        didSet {
            guard let text = messageText else { return }
            let width = estimateFlameForTextView(text: text).width + 20
            
            messageTextViewWidthConstraint.constant = width
            messageTextView.text = text
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
}
