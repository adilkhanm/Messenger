//
//  NetworkController.swift
//  Messenger
//
//  Created by Adilkhan Muratov on 16.05.2022.
//

import Foundation
import Alamofire
import FirebaseAuth
import FirebaseFirestore

class NetworkController {
    private static let BASE_URL = "https://firestore.googleapis.com/v1/projects/messengerapp-dac82/databases/(default)/documents/"
    private static let USERS = "users"
    private static let CONVERSATIONS = "conversations"
    
    typealias CompletionHandler = (_ result: Any) -> Void
    
    static func post(user: User, completion: @escaping (Error?) -> Void) {
//        let url = BASE_URL + USERS
        let data: [String: Any] = [
            "firstname": user.firstname,
            "lastname": user.lastname,
            "uid": user.uid
        ]
//        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON { response in
//            print(response)
//            completion(nil)
//        }
        let db = Firestore.firestore()
        db.collection(USERS).addDocument(data: data) { (error) in
            completion(error)
        }
                        
    }
    
    static func getUsers(completion: @escaping CompletionHandler) {
        let url = BASE_URL + USERS
        AF.request(url).responseDecodable(of: UsersResponse.self) { (response) in
            guard let users = response.value else { return }
            completion(users.users)
        }
    }
    
    static func getUser(uid: String, completion: @escaping CompletionHandler) {
        getUsers() { result in
            guard let users = result as? [User] else { return }
//            print("USERS:\n\(users)")
            for user in users {
//                print("checking \(user.uid) \(uid) => \(user.uid == uid)")
                if user.uid == uid {
                    completion(user)
                }
            }
        }
    }
    
    static func getUser(completion: @escaping CompletionHandler) {
        let currentUser = Auth.auth().currentUser
        
        if let currentUser = currentUser {
            let uid = currentUser.uid
//            print("UID: \(uid)")
            self.getUser(uid: uid) { result in
                guard let user = result as? User else { return }
                completion(user)
            }
        }
    }
    
}

// MARK: - Getting & Sending messages
extension NetworkController {
    
    public static func getConversation(with otherUserUid: String, completion: @escaping (Conversation?) -> Void) {
        let url = BASE_URL + CONVERSATIONS
        guard let uid = Auth.auth().currentUser?.uid else { return }

        AF.request(url).responseDecodable(of: ConversationResponse.self) { (response) in
            if let conversations = response.value?.conversations {
                var result: Conversation? = nil
                for conversation in conversations {
                    if conversation.members.contains(otherUserUid) && conversation.members.contains(uid) {
                        result = conversation
                    }
                }
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
    
    public static func conversationExists(with otherUserUid: String, completion: @escaping (Bool) -> Void) {
        self.getConversation(with: otherUserUid) { conversation in
            completion(conversation != nil)
        }
    }
    
    public static func createNewConversation(with otherUserUid: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") else { return }
        
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
            break
        default:
            message = ""
        }
        
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "members": [
                uid,
                otherUserUid
            ],
            "messages": [
                [
                    "from":uid,
                    "text":message,
                    "date":Utilities.dateFormatter.string(from: Date())
                ]
            ]
        ]
        db.collection(CONVERSATIONS).addDocument(data: data) { error in
            completion(error == nil)
        }
        
    }
    
    public static func getLastMessage(with otherUserId: String, completion: @escaping (MyMessage?) -> Void) {
        self.getConversation(with: otherUserId) { conversation in
            if let conversation = conversation {
                completion(conversation.messages.last)
            } else {
                completion(nil)
            }
        }
    }
    
    public static func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
    
}
