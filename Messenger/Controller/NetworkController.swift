//
//  NetworkController.swift
//  Messenger
//
//  Created by Adilkhan Muratov on 16.05.2022.
//

import Foundation
import Alamofire
import FirebaseAuth

struct NetworkController {
    private static let BASE_URL = "https://firestore.googleapis.com/v1/projects/messengerapp-dac82/databases/(default)/documents/"
    private static let USERS = "users"
    private static let MESSAGES = "messages"
    
    static func getUsers() -> [User] {
        var result: [User] = []
        
        let url = BASE_URL + USERS
        AF.request(url).responseDecodable(of: UsersResponse.self) { (response) in
            guard let users = response.value else { return }
            result = users.users
            
        }
        
        return result
    }
    
    static func getUser(uid: String) -> User? {
        let users = getUsers()
        print("USERS:\n\(users)")
        for user in users {
            if user.uid == uid {
                return user
            }
        }
        return nil
    }
    
    static func getUser() -> User? {
        let currentUser = Auth.auth().currentUser
        
        print("HI!")
        if let currentUser = currentUser {
            let uid = currentUser.uid
            print(uid)
            return self.getUser(uid: uid)
        }
        
        return nil
    }
}
