//
//  DataManager.swift
//  BoardNote
//
//  Data Management Service
//

import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var boards: [Board] = []
    @Published var user: User = User()
    @Published var settings: AppSettings = AppSettings()
    @Published var achievements: [Achievement] = Achievement.allAchievements
    
    private let boardsKey = "boards"
    private let userKey = "user"
    private let settingsKey = "settings"
    private let achievementsKey = "achievements"
    
    init() {
        loadAllData()
    }
    
    // MARK: - Load Data
    func loadAllData() {
        loadBoards()
        loadUser()
        loadSettings()
        loadAchievements()
    }
    
    private func loadBoards() {
        if let data = UserDefaults.standard.data(forKey: boardsKey),
           let decoded = try? JSONDecoder().decode([Board].self, from: data) {
            boards = decoded
        }
    }
    
    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let decoded = try? JSONDecoder().decode(User.self, from: data) {
            user = decoded
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            achievements = Achievement.allAchievements
        }
    }
    
    // MARK: - Save Data
    func saveBoards() {
        if let encoded = try? JSONEncoder().encode(boards) {
            UserDefaults.standard.set(encoded, forKey: boardsKey)
        }
    }
    
    func saveUser() {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    // MARK: - Board Operations
    func addBoard(_ board: Board) {
        var newBoard = board
        
        // Generate thumbnail immediately
        if let thumbnailData = BoardPreviewGenerator.generateThumbnail(for: board) {
            newBoard.thumbnailData = thumbnailData
        }
        
        boards.append(newBoard)
        saveBoards()
        
        checkAchievement("first_board")
        checkAchievement("organizer")
    }
    
    func updateBoard(_ board: Board) {
        if let index = boards.firstIndex(where: { $0.id == board.id }) {
            var updatedBoard = board
            updatedBoard.updatedAt = Date()
            
            // Generate thumbnail - keep existing if generation fails
            if let thumbnailData = BoardPreviewGenerator.generateThumbnail(for: board) {
                updatedBoard.thumbnailData = thumbnailData
            } else if updatedBoard.thumbnailData == nil {
                // If no thumbnail exists and generation failed, keep the old one
                updatedBoard.thumbnailData = boards[index].thumbnailData
            }
            
            boards[index] = updatedBoard
            saveBoards()
        }
    }
    
    func deleteBoard(_ board: Board) {
        boards.removeAll { $0.id == board.id }
        saveBoards()
    }
    
    // MARK: - Achievement System
    func checkAchievement(_ achievementId: String) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }) else { return }
        
        if achievements[index].isUnlocked { return }
        
        var shouldUnlock = false
        
        switch achievementId {
        case "first_board":
            shouldUnlock = boards.count >= 1
        case "organizer":
            shouldUnlock = boards.count >= 3
        case "photo_master":
            let photoCount = boards.flatMap { $0.elements }.filter { $0.type == .photo }.count
            achievements[index].progress = photoCount
            shouldUnlock = photoCount >= 10
        case "text_guru":
            let textCount = boards.flatMap { $0.elements }.filter { $0.type == .text }.count
            achievements[index].progress = textCount
            shouldUnlock = textCount >= 10
        case "connector":
            let arrowCount = boards.flatMap { $0.elements }.filter { $0.type == .arrow }.count
            achievements[index].progress = arrowCount
            shouldUnlock = arrowCount >= 5
        case "link_master":
            let arrowCount = boards.flatMap { $0.elements }.filter { $0.type == .arrow }.count
            achievements[index].progress = arrowCount
            shouldUnlock = arrowCount >= 10
        case "cleanup":
            // This needs to be tracked separately
            shouldUnlock = achievements[index].progress >= 5
        case "editor":
            // Unlocked when user edits any element
            shouldUnlock = achievements[index].progress >= 1
        default:
            break
        }
        
        if shouldUnlock {
            achievements[index].isUnlocked = true
            achievements[index].unlockedAt = Date()
            saveAchievements()
        }
    }
    
    func trackAction(_ action: String) {
        switch action {
        case "delete_element":
            if let index = achievements.firstIndex(where: { $0.id == "cleanup" }) {
                achievements[index].progress += 1
                checkAchievement("cleanup")
            }
        case "edit_element":
            if let index = achievements.firstIndex(where: { $0.id == "editor" }) {
                achievements[index].progress += 1
                checkAchievement("editor")
            }
        default:
            break
        }
    }
}

