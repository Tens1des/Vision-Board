//
//  BoardElement.swift
//  BoardNote
//
//  Board Element Model
//

import Foundation
import CoreGraphics

enum ElementType: String, Codable {
    case photo
    case text
    case sticker
    case arrow
    case shape
    
    var displayName: String {
        switch self {
        case .photo:
            return LocalizedStrings.photo
        case .text:
            return LocalizedStrings.text
        case .sticker:
            return LocalizedStrings.sticker
        case .arrow:
            return LocalizedStrings.arrow
        case .shape:
            return LocalizedStrings.shape
        }
    }
}

enum ShapeType: String, Codable {
    case circle
    case square
    case triangle
}

struct BoardElement: Identifiable, Codable {
    var id = UUID()
    var type: ElementType
    var position: CGPoint
    var size: CGSize
    var rotation: Double
    var scale: Double
    
    // Content
    var text: String?
    var imageData: Data?
    var color: String? // Hex color
    var shapeType: ShapeType?
    
    // For arrows
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var arrowColor: String?
    var lineWidth: Double?
    
    var createdAt: Date
    var updatedAt: Date
    
    init(type: ElementType, position: CGPoint = .zero) {
        self.type = type
        self.position = position
        self.size = CGSize(width: 150, height: 150)
        self.rotation = 0
        self.scale = 1.0
        self.createdAt = Date()
        self.updatedAt = Date()
        
        // Set defaults based on type
        switch type {
        case .text:
            self.text = "New Note"
            self.size = CGSize(width: 200, height: 100)
            self.color = "#FFFFFF" // White background for text notes
        case .sticker:
            self.color = "#FF6B6B"
            self.size = CGSize(width: 120, height: 120)
        case .shape:
            self.shapeType = .circle
            self.color = "#4ECDC4"
            self.size = CGSize(width: 80, height: 80)
        case .arrow:
            self.startPoint = position
            self.endPoint = CGPoint(x: position.x + 100, y: position.y + 100)
            self.arrowColor = "#95E1D3"
            self.lineWidth = 3
        default:
            break
        }
    }
}
