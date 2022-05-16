//
//  SignupViewController.swift
//  Messenger
//
//  Created by Adilkhan Muratov on 15.05.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD

class SignupViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let profileImageView: UIImageView = Utilities.getProfilePictureView()
    
    private let firstnameTextField: UITextField = Utilities.createTextField(placeholder: "First name")
    private let lastnameTextField: UITextField = Utilities.createTextField(placeholder: "Last name")
    private let emailTextField: UITextField = Utilities.createTextField(placeholder: "Email")
    private let passwordTextField: UITextField = Utilities.createTextField(placeholder: "Password", isSecured: true)
    
    private let signupButton: UIButton = Utilities.createButton(title: "Sign Up", color: .systemGreen)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sign Up"
        view.backgroundColor = .white
        
        signupButton.addTarget(self, action: #selector(didTapSignupButton), for: .touchUpInside)
        addSubviews()
    
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(profileImageView)
        scrollView.addSubview(firstnameTextField)
        scrollView.addSubview(lastnameTextField)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(signupButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        profileImageView.frame = CGRect(x: (view.width - size) / 2, y: 20, width: size, height: size)
        profileImageView.layer.cornerRadius = profileImageView.width / 2
        firstnameTextField.frame = CGRect(x: 30, y: profileImageView.bottom + 10, width: scrollView.width - 60, height: 52)
        lastnameTextField.frame = CGRect(x: 30, y: firstnameTextField.bottom + 10, width: scrollView.width - 60, height: 52)
        emailTextField.frame = CGRect(x: 30, y: lastnameTextField.bottom + 10, width: scrollView.width - 60, height: 52)
        passwordTextField.frame = CGRect(x: 30, y: emailTextField.bottom + 10, width: scrollView.width - 60, height: 52)
        signupButton.frame = CGRect(x: 30, y: passwordTextField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    @objc private func didTapSignupButton() {
        
        guard let firstname = firstnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let lastname = lastnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !firstname.isEmpty, !lastname.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 8 else {
            alertError(message: "Please enter data to all the fields")
            return
        }
        
        spinner.show(in: view)
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            
            if error != nil {
                strongSelf.alertError(message: "Error creating user!")
            } else {
//                let db = Firestore.firestore()
                
                let new_user = User(firstname: firstname, lastname: lastname, uid: result!.user.uid)
                NetworkController.post(user: new_user) { error in
                    if error != nil {
                        strongSelf.alertError(message: "Error saving user data!")
                    }
                }
                
                UserDefaults.standard.set(result!.user.uid, forKey: "uid")
                
                strongSelf.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    private func alertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}
