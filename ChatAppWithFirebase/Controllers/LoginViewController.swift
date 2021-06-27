//
//  LoginViewController.swift
//  ChatAppWithFirebase
//
//  Created by 木内悠太 on 2021/06/06.
//

import UIKit
import Firebase
import FirebaseAuth
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var dontHaveAccountButton: UIButton!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.isEnabled = false
        loginButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        loginButton.layer.cornerRadius = 8
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(textFieldDidChangeSelection(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChangeSelection(_:)), for: .editingChanged)
    }
    

    
    @objc private func tappedDontHaveAccountButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        HUD.show(.progress)
        Auth.auth().signIn(withEmail: email, password: password){(res,err) in
            if let err = err {
                let dialog = UIAlertController(title: "", message: "メールアドレスもしくはパスワードが異なります",  preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
                HUD.hide()
                return
            }
            HUD.hide()
            let nav = self.presentingViewController as! UINavigationController
            let chatListViewController = nav.viewControllers[nav.viewControllers.count-1] as? ChatListViewController
            chatListViewController?.fetchChatroomsInfoFromFirestore()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (UITraitCollection.current.userInterfaceStyle == .dark) {
            emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            emailTextField.backgroundColor = UIColor.gray
            passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            passwordTextField.backgroundColor = UIColor.gray
//            loginButton.backgroundColor = .rgb(red: 100, green: 255, blue: 100)

        } else {
//            emailTextField.attributedPlaceholder = NSAttributedString(string:  emailTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
//            passwordTextField.attributedPlaceholder = NSAttributedString(string:  passwordTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
//            passwordTextField.backgroundColor = UIColor.
        }
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField){
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        if emailIsEmpty || passwordIsEmpty {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
    }
}
