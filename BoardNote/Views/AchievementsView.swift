//
//  AchievementsView.swift
//  BoardNote
//
//  Achievements Screen
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var dataManager = DataManager.shared
    
    var unlockedCount: Int {
        dataManager.achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        dataManager.achievements.count
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 150)
                            
                            VStack(spacing: 8) {
                                Text("🏆")
                                    .font(.system(size: 60))
                                
                                Text("Achievement Progress")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(unlockedCount) of \(totalCount)")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Overall Progress")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(Int((Double(unlockedCount) / Double(totalCount)) * 100))%")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appPrimary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(unlockedCount) / CGFloat(totalCount), height: 12)
                            }
                        }
                        .frame(height: 12)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    
                    // Achievements List
                    VStack(spacing: 12) {
                        ForEach(dataManager.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.appPrimary.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Text(achievement.icon)
                    .font(.system(size: 32))
                    .grayscale(achievement.isUnlocked ? 0 : 1)
                    .opacity(achievement.isUnlocked ? 1 : 0.5)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .black : .gray)
                
                Text(achievement.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                // Progress for achievements with targets > 1
                if achievement.target > 1 {
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.appPrimary)
                                    .frame(width: min(geometry.size.width * CGFloat(achievement.progress) / CGFloat(achievement.target), geometry.size.width), height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        Text("\(achievement.progress)/\(achievement.target)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(width: 40)
                    }
                }
            }
            
            Spacer()
            
            // Status
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.appSecondary)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(achievement.isUnlocked ? 0.08 : 0.03), radius: 8, x: 0, y: 2)
    }
}

