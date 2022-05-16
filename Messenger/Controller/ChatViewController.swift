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
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public let otherUserUid: String
    public let otherUser: User
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        return Sender(senderId: uid, displayName: "You")
    }
    
    private var otherSender: Sender? {
        return Sender(senderId: otherUserUid, displayName: otherUser.firstname)
    }

    init(with uid: String, user: User) {
        self.otherUserUid = uid
        self.otherUser = user
        super.init(nibName: nil, bundle: nil)
        
        fetchMessages()
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
    
    func fetchMessages() {
        self.messages = []
        NetworkController.getConversation(with: otherUserUid) { [weak self] conversation in
            var allmessages: [Message] = []
            if let conversation = conversation {
                let mymessages = conversation.messages
                for message in mymessages {
                    allmessages.append(Message(sender: (message.from == self?.otherUserUid ? self?.otherSender : self?.selfSender)!,
                                               messageId: "\(message.from)_\(message.text)_\(message.date)",
                                               sentDate: Date(),
                                               kind: .text(message.text)))
                }
            }
            
            self?.messages = allmessages
            DispatchQueue.main.async {
                self?.messagesCollectionView.reloadData()
            }
        }
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
        
        NetworkController.conversationExists(with: otherUserUid) { exists in
            if exists == false {
                NetworkController.createNewConversation(with: self.otherUserUid, firstMessage: message) { [weak self] success in
                    if success {
                        print("message is sent")
                    } else {
                        print("message was not sent")
                    }
                    self?.messages.append(message)
                    self?.messagesCollectionView.reloadData()
                }
            } else {
                NetworkController.getConversationId(with: self.otherUserUid) { conversationUid in
                    if let conversationUid = conversationUid {
                        NetworkController.sendMessage(to: conversationUid, newMessage: message) { [weak self] success in
                            if success {
                                print("message is sent")
                            } else {
                                print("message was not sent")
                            }
                            self?.messages.append(message)
                            self?.messagesCollectionView.reloadData()
                        }
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
        return messages.count
    }
    
    
}
