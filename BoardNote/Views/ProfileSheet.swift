//
//  ProfileSheet.swift
//  BoardNote
//
//  Profile and Stats Sheet
//

import SwiftUI

struct ProfileSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var dataManager = DataManager.shared
    @State private var showingSettings = false
    @State private var showingAchievements = false
    @State private var showingAvatarPicker = false
    
    var userLevel: Int {
        let totalBoards = dataManager.boards.count
        let totalElements = dataManager.boards.flatMap { $0.elements }.count
        let unlockedAchievements = dataManager.achievements.filter { $0.isUnlocked }.count
        
        return min(10, (totalBoards + totalElements + unlockedAchievements) / 5 + 1)
    }
    
    var userXP: Int {
        let totalBoards = dataManager.boards.count * 50
        let totalElements = dataManager.boards.flatMap { $0.elements }.count * 10
        let unlockedAchievements = dataManager.achievements.filter { $0.isUnlocked }.count * 100
        
        return totalBoards + totalElements + unlockedAchievements
    }
    
    var xpToNextLevel: Int {
        let currentLevelXP = (userLevel - 1) * 500
        let nextLevelXP = userLevel * 500
        return nextLevelXP - (userXP - currentLevelXP)
    }
    
    var progressToNextLevel: Double {
        let currentLevelXP = (userLevel - 1) * 500
        let currentLevelProgress = userXP - currentLevelXP
        return min(1.0, Double(currentLevelProgress) / 500.0)
    }
    
    var recentAchievements: [Achievement] {
        dataManager.achievements
            .filter { $0.isUnlocked }
            .sorted { ($0.unlockedAt ?? Date.distantPast) > ($1.unlockedAt ?? Date.distantPast) }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // User Profile Card
                        userProfileCard
                        
                        // Recent Achievements
                        if !recentAchievements.isEmpty {
                            recentAchievementsSection
                        }
                        
                        // Navigation Sections
                        navigationSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView()
        }
        .sheet(isPresented: $showingAvatarPicker) {
            AvatarPickerView(isPresented: $showingAvatarPicker)
        }
    }
    
    // MARK: - User Profile Card
    private var userProfileCard: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                // Avatar
                Button(action: { showingAvatarPicker = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: dataManager.user.avatarColor), Color(hex: dataManager.user.avatarColor).opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Color(hex: dataManager.user.avatarColor).opacity(0.3), radius: 15, x: 0, y: 8)
                        
                        Image(systemName: dataManager.user.avatarIcon)
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                        
                        // Level badge
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 8, y: 8)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(dataManager.user.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                // Level and XP
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    
                    Text("Level \(userLevel) - \(userXP) XP")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(width: geometry.size.width * progressToNextLevel, height: 8)
                    }
                }
                .frame(height: 8)
                
                Text("To level \(userLevel + 1): \(xpToNextLevel) XP")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Stats
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(dataManager.boards.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Boards")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                VStack(spacing: 4) {
                    Text("\(dataManager.boards.flatMap { $0.elements }.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Elements")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                VStack(spacing: 4) {
                    Text("\(dataManager.achievements.filter { $0.isUnlocked }.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Achievements")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Recent Achievements Section
    private var recentAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Achievements")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            VStack(spacing: 12) {
                ForEach(recentAchievements) { achievement in
                    HStack(spacing: 16) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(getAchievementColor(for: achievement.id).opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Text(achievement.icon)
                                .font(.system(size: 24))
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 4) {
                            Text(achievement.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text(achievement.description)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Status
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
            }
        }
    }
    
    // MARK: - Navigation Section
    private var navigationSection: some View {
        VStack(spacing: 12) {
            // Settings
            Button(action: { showingSettings = true }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("Personalization and management")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
            
            // Achievements
            Button(action: { showingAchievements = true }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "trophy")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Achievements")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("\(dataManager.achievements.filter { $0.isUnlocked }.count)/\(dataManager.achievements.count)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Text("Your awards and progress")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getAchievementColor(for id: String) -> Color {
        switch id {
        case "first_board": return .blue
        case "photo_master": return .green
        case "text_guru": return .orange
        case "connector": return .purple
        case "minimalist": return .pink
        case "organizer": return .red
        case "combined": return .yellow
        case "editor": return .indigo
        case "architect": return .cyan
        case "link_master": return .mint
        case "cleanup": return .brown
        case "inspiration": return .yellow
        default: return .gray
        }
    }
}
