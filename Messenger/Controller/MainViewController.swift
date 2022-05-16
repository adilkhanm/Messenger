//
//  ViewController.swift
//  Messenger
//
//  Created by Adilkhan Muratov on 14.05.2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class MainViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    public var otherUsers: [User] = []
    public var messages: [MyMessage?] = []
    public var order: [Int] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
        self.tableView.reloadData()
        
        NetworkController.getUsers() { result in
            guard let users = result as? [User],
                  let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            var other: [User] = []
            var messages: [MyMessage?] = []
            var order: [Int] = []
            for user in users {
                if user.uid != uid {
                    let index = other.count
                    other.append(user)
                    messages.append(nil)
                    order.append(index)
                    
                    NetworkController.getLastMessage(with: user.uid) { message in
                        messages[index] = message
                    }
                }
            }
            
            self.order = order.sorted(by: {
                if messages[$0] == nil && messages[$1] == nil {
                    return $0 < $1
                } else if messages[$0] == nil {
                    return false
                } else if messages[$1] == nil {
                    return true
                } else {
                    return messages[$0]!.date > messages[$1]!.date
                }
            })
            
//            print("DATE: \(String(describing: messages[self.order[0]]?.date))")
//            print("DATE: \(String(describing: messages[self.order[1]]?.date))")
            
            self.otherUsers = other
            self.messages = messages
            self.tableView.reloadData()
        }
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        let index = self.order[indexPath.row]
        cell.configure(with: otherUsers[index])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherUsers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let index = self.order[indexPath.row]
        let chatVC = ChatViewController(with: otherUsers[index].uid, user: otherUsers[index])
        
        chatVC.title = "\(otherUsers[index].firstname) \(otherUsers[index].lastname)"
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

}
