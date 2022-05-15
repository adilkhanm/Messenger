//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Adilkhan Muratov on 15.05.2022.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let sharedInstance = DatabaseManager()
    
    private let db = Firestore.firestore()
    
    
}
