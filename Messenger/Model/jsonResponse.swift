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
}

struct StringValue: Codable {
    let value: String
    
    private enum CodingKeys: String, CodingKey {
        case value = "stringValue"
    }
}
