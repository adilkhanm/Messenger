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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableViewHeader()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.data = ["Log Out"]
        self.tableView.reloadData()
        
        NetworkController.getUser() { result in
            guard let user = result as? User else { return }
            self.data = [user.firstname, user.lastname, "Log Out"]
            self.tableView.reloadData()
        }
    }
    
    func createTableViewHeader() -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .white
        let imageView = Utilities.getProfilePictureView()
        
        imageView.frame = CGRect(x: (view.width - 150) / 2, y: 75, width: 150, height: 150)
        imageView.layer.cornerRadius = imageView.width / 2
        headerView.addSubview(imageView)
        return headerView
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
        } else {
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
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
