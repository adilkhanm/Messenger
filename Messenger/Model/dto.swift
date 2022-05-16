//
//  usersResponse.swift
//  Messenger
//
//  Created by Adilkhan Muratov on 16.05.2022.
//

import Foundation

struct UsersResponse: Codable {
    let users: [User]
    
    private enum CodingKeys: String, CodingKey {
        case users = "documents"
    }
}

struct User: Codable {
    let firstname: String
    let lastname: String
    let uid: String
    let lastMessage: MyMessage? = nil
    
    private enum UserKeys: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case firstname
        case lastname
        case uid
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserKeys.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        self.firstname = try fieldContainer.decode(StringValue.self, forKey: .firstname).value
        self.lastname = try fieldContainer.decode(StringValue.self, forKey: .lastname).value
        self.uid = try fieldContainer.decode(StringValue.self, forKey: .uid).value
    }
    
    init(firstname: String, lastname: String, uid: String) {
        self.firstname = firstname
        self.lastname = lastname
        self.uid = uid
    }
}

struct StringValue: Codable {
    let value: String
    
    private enum CodingKeys: String, CodingKey {
        case value = "stringValue"
    }
}

struct ConversationResponse: Codable {
    let conversations: [Conversation]
    
    private enum CodingKeys: String, CodingKey {
        case conversations = "documents"
    }
}


struct Conversation: Codable {
    let members: [String]
    let messages: [MyMessage]
    
    private enum ConversationKeys: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case members
        case messages
    }
    
    private enum ArrayKeys: String, CodingKey {
        case arrayValue
    }
    
    private enum ArrayValuesKeys: String, CodingKey {
        case values
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ConversationKeys.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
//        debugPrint("Field Container: \(fieldContainer.allKeys)")
        
        let membersArrayContainer = try fieldContainer.nestedContainer(keyedBy: ArrayKeys.self, forKey: .members)
        let messagesArrayContainer = try fieldContainer.nestedContainer(keyedBy: ArrayKeys.self, forKey: .messages)
        let membersContainer = try membersArrayContainer.nestedContainer(keyedBy: ArrayValuesKeys.self, forKey: .arrayValue)
        let messagesContainer = try messagesArrayContainer.nestedContainer(keyedBy: ArrayValuesKeys.self, forKey: .arrayValue)
        
        self.members = try membersContainer.decode([StringValue].self, forKey: .values).map { $0.value }
        self.messages = try messagesContainer.decode([MyMessage].self, forKey: .values)
    }
}

struct MyMessage: Codable {
    let from: String
    let text: String
    let date: String
    
    private enum MessagesKeys: String, CodingKey {
        case mapValue
    }
    
    private enum MapKeys: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case from
        case text
        case date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MessagesKeys.self)
        let mapContainer = try container.nestedContainer(keyedBy: MapKeys.self, forKey: .mapValue)
        let fieldContainer = try mapContainer.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        self.from = try fieldContainer.decode(StringValue.self, forKey: .from).value
        self.text = try fieldContainer.decode(StringValue.self, forKey: .text).value
        self.date = try fieldContainer.decode(StringValue.self, forKey: .date).value
    }
}
