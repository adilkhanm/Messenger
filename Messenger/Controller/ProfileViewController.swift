//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Adilkhan Muratov on 15.05.2022.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let user = NetworkController.getUser()
//        data = []
//        if let user = user {
//            data = [user.firstname, user.lastname, "Log Out"]
//        }
        
        data = ["Log Out"]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func didTapLogout() {
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            do {
                try Auth.auth().signOut()
                
                let loginVC = LoginViewController()
                let nav = UINavigationController(rootViewController: loginVC)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            } catch let signoutError as NSError {
                print("Error logging out: \(signoutError)")
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
        
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        if indexPath.row == data.count - 1 {
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == data.count - 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            self.didTapLogout()
        }
    }
}
