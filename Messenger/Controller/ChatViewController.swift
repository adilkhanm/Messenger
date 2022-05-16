//
//  ChatViewController.swift
//  Messenger
//
//  Created by Adilkhan Muratov on 16.05.2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

struct Sender: SenderType {
//    var photoUrl: String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public let otherUserUid: String
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        return Sender(senderId: uid, displayName: "You")
    }

    init(with uid: String) {
        self.otherUserUid = uid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
        
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        print("message => \(message)")
        
        NetworkController.conversationExists(with: otherUserUid) { exists in
            if exists == false {
                NetworkController.createNewConversation(with: self.otherUserUid, firstMessage: message) { success in
                    if success {
                        print("message is sent")
                    } else {
                        print("message was not sent")
                    }
                }
            } else {
                NetworkController.sendMessage(to: self.otherUserUid, message: message) { success in
                    if success {
                        print("message is sent")
                    } else {
                        print("message was not sent")
                    }
                }
            }
        }
    }
    
    private func createMessageId() -> String? {
        let dateString = Utilities.dateFormatter.string(from: Date())
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") else {
            return nil
            
        }
        
        let newid = "\(otherUserUid)_\(currentUid)_\(dateString)"
        return newid
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}
