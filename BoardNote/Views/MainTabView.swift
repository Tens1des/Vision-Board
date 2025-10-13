//
//  MainTabView.swift
//  BoardNote
//
//  Main Tab Bar Navigation
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: "square.grid.2x2")
                        Text("Boards")
                    }
                }
                .tag(0)
            
            // Achievements Tab
            AchievementsTabView()
                .tabItem {
                    VStack {
                        Image(systemName: "trophy.fill")
                        Text("Achievements")
                    }
                }
                .tag(1)
            
            // Profile Tab
            ProfileTabView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }
                .tag(2)
        }
        .accentColor(.appPrimary)
    }
}

// MARK: - Achievements Tab View
struct AchievementsTabView: View {
    @ObservedObject var dataManager = DataManager.shared
    
    var unlockedAchievements: [Achievement] {
        dataManager.achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        dataManager.achievements.filter { !$0.isUnlocked }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Stats Header
                        statsHeader
                        
                        // Unlocked Achievements
                        if !unlockedAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Unlocked")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                
                                ForEach(unlockedAchievements) { achievement in
                                    AchievementCard(achievement: achievement)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        
                        // Locked Achievements
                        if !lockedAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Locked")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                
                                ForEach(lockedAchievements) { achievement in
                                    AchievementCard(achievement: achievement)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var statsHeader: some View {
        VStack(spacing: 16) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 140, height: 140)
                
                Circle()
                    .trim(from: 0, to: CGFloat(unlockedAchievements.count) / CGFloat(dataManager.achievements.count))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(unlockedAchievements.count)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.appPrimary)
                    Text("of \(dataManager.achievements.count)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Text("Achievements Unlocked")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Profile Tab View
struct ProfileTabView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showingSettings = false
    @State private var showingAvatarPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: dataManager.user.avatarColor).opacity(0.15),
                        Color.appBackground
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader
                        
                        // Stats Cards
                        statsCards
                        
                        // Menu Items
                        menuItems
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingAvatarPicker) {
                AvatarPickerView(isPresented: $showingAvatarPicker)
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 20) {
            // Avatar
            Button(action: { showingAvatarPicker = true }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: dataManager.user.avatarColor),
                                    Color(hex: dataManager.user.avatarColor).opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(hex: dataManager.user.avatarColor).opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: dataManager.user.avatarIcon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.white)
                    
                    // Edit icon
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: dataManager.user.avatarColor))
                            }
                            .offset(x: 8, y: 8)
                        }
                    }
                    .frame(width: 100, height: 100)
                }
            }
            
            // Name
            Text(dataManager.user.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Text("Vision Board Creator")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 20)
    }
    
    private var statsCards: some View {
        HStack(spacing: 16) {
            statCard(
                title: "Boards",
                value: "\(dataManager.boards.count)",
                icon: "square.grid.2x2",
                color: "#4A90E2"
            )
            
            statCard(
                title: "Elements",
                value: "\(dataManager.boards.reduce(0) { $0 + $1.elements.count })",
                icon: "square.stack.3d.up",
                color: "#2CB67D"
            )
            
            statCard(
                title: "Achievements",
                value: "\(dataManager.achievements.filter { $0.isUnlocked }.count)",
                icon: "trophy.fill",
                color: "#F39C12"
            )
        }
        .padding(.horizontal, 20)
    }
    
    private func statCard(title: String, value: String, icon: String, color: String) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: color))
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var menuItems: some View {
        VStack(spacing: 12) {
            menuItem(
                icon: "gearshape.fill",
                title: "Settings",
                subtitle: "App preferences",
                color: "#7F5AF0"
            ) {
                showingSettings = true
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func menuItem(icon: String, title: String, subtitle: String, color: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: color).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: color))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

