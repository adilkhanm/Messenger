//
//  LoginViewController.swift
//  Messenger
//
//  Created by Adilkhan Muratov on 15.05.2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "messengericon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailTextField: UITextField = Utilities.createTextField(placeholder: "Email")
    private let passwordTextField: UITextField = Utilities.createTextField(placeholder: "Password", isSecured: true)
    
    private let loginButton: UIButton = Utilities.createButton(title: "Sign In", color: .link)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Up", style: .done, target: self, action: #selector(didTapSignupButton))
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        addSubviews()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        logoImageView.frame = CGRect(x: (view.width - size) / 2, y: 20, width: size, height: size)
        emailTextField.frame = CGRect(x: 30, y: logoImageView.bottom + 10, width: scrollView.width - 60, height: 52)
        passwordTextField.frame = CGRect(x: 30, y: emailTextField.bottom + 10, width: scrollView.width - 60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordTextField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    @objc private func didTapLoginButton() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertError(message: "Please enter data to all the fields")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            if error != nil {
                strongSelf.alertError(message: error!.localizedDescription)
            } else {
                strongSelf.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    private func alertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapSignupButton() {
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
}
