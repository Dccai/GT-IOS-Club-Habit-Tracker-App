//
//  User.swift
//  IOS Habit Tracker App Project
//
//  Created by user940897 on 11/3/25.
//

import Foundation
import FirebaseFirestore


struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var habits: [Habit]
    
}
