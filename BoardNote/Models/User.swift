//
//  User.swift
//  BoardNote
//
//  User Model
//

import Foundation

struct User: Codable {
    var name: String
    var avatarIcon: String
    var avatarColor: String
    var lastUsedSticker: String?
    
    init(name: String = "User", avatarIcon: String = "person.fill", avatarColor: String = "#7F5AF0", lastUsedSticker: String? = nil) {
        self.name = name
        self.avatarIcon = avatarIcon
        self.avatarColor = avatarColor
        self.lastUsedSticker = lastUsedSticker
    }
}

