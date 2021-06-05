//
//  LoginViewController.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/06/06.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextView: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var dontHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 8
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
    }
    
    @objc private func tappedDontHaveAccountButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextView.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password){(res,err) in
            if let err = err {
                print("ログインに失敗しました\(err)")
                return
            }
            print("ログインに成功しました")
            let nav = self.presentingViewController as! UINavigationController
            let chatListViewController = nav.viewControllers[nav.viewControllers.count-1] as? ChatListViewController
            chatListViewController?.fetchChatroomsInfoFromFirestore()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
