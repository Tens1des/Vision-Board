//
//  AppSettings.swift
//  BoardNote
//
//  App Settings Model
//

import Foundation

struct AppSettings: Codable {
    var language: AppLanguage
    var autoSave: Bool
    var showGrid: Bool
    var fontSize: FontSize
    
    init() {
        self.language = .english
        self.autoSave = true
        self.showGrid = true
        self.fontSize = .medium
    }
}

enum AppLanguage: String, Codable, CaseIterable {
    case english = "English"
    case russian = "Русский"
}

enum FontSize: String, Codable, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var scale: CGFloat {
        switch self {
        case .small: return 0.8
        case .medium: return 1.0
        case .large: return 1.4
        }
    }
}

