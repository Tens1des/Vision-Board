//
//  Achievement.swift
//  BoardNote
//
//  Achievement Model
//

import Foundation

struct Achievement: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var isUnlocked: Bool
    var unlockedAt: Date?
    var progress: Int
    var target: Int
    
    init(id: String, title: String, description: String, icon: String, target: Int = 1) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = false
        self.progress = 0
        self.target = target
    }
}

extension Achievement {
    static var allAchievements: [Achievement] {
        [
            Achievement(id: "first_board", title: "First Board", description: "Created your first vision board.", icon: "🎯", target: 1),
            Achievement(id: "photo_master", title: "Photo Master", description: "Added 10 photos to boards.", icon: "📸", target: 10),
            Achievement(id: "text_guru", title: "Text Guru", description: "Created 10 text notes.", icon: "📝", target: 10),
            Achievement(id: "connector", title: "Connector", description: "Connected 5 elements with arrows.", icon: "🔗", target: 5),
            Achievement(id: "minimalist", title: "Minimalist", description: "Made a board with only stickers and text (no photos).", icon: "✨", target: 1),
            Achievement(id: "organizer", title: "Organizer", description: "Created 3 boards and named them.", icon: "📋", target: 3),
            Achievement(id: "combined", title: "Combined", description: "Used all element types on one board (Photo, Text, Sticker, Arrow).", icon: "🎨", target: 1),
            Achievement(id: "editor", title: "Editor", description: "Edited an element: changed size, color or caption.", icon: "✏️", target: 1),
            Achievement(id: "architect", title: "Architect", description: "Created a board with at least 3 grouped elements.", icon: "🏗️", target: 1),
            Achievement(id: "link_master", title: "Link Master", description: "Drew 10 arrows between elements.", icon: "➡️", target: 10),
            Achievement(id: "cleanup", title: "Cleanup", description: "Deleted 5 elements from board.", icon: "🗑️", target: 5),
            Achievement(id: "inspiration", title: "Inspiration Master", description: "Viewed board in Presentation mode at least 3 times.", icon: "⭐", target: 3)
        ]
    }
}

