//
//  Board.swift
//  BoardNote
//
//  Vision Board Model
//

import Foundation
import SwiftUI

struct Board: Identifiable, Codable {
    var id = UUID()
    var title: String
    var elements: [BoardElement]
    var thumbnailData: Data?
    var createdAt: Date
    var updatedAt: Date
    var year: String?
    var iconEmoji: String?
    var iconPhotoData: Data?
    
    init(title: String, year: String? = nil, iconEmoji: String? = nil, iconPhotoData: Data? = nil) {
        self.title = title
        self.elements = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.year = year
        self.iconEmoji = iconEmoji
        self.iconPhotoData = iconPhotoData
    }
    
    mutating func addElement(_ element: BoardElement) {
        elements.append(element)
        updatedAt = Date()
    }
    
    mutating func removeElement(_ element: BoardElement) {
        elements.removeAll { $0.id == element.id }
        updatedAt = Date()
    }
    
    mutating func updateElement(_ element: BoardElement) {
        if let index = elements.firstIndex(where: { $0.id == element.id }) {
            elements[index] = element
            updatedAt = Date()
        }
    }
}

