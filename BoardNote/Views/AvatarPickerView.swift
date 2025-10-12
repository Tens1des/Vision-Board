//
//  AvatarPickerView.swift
//  BoardNote
//
//  Avatar Selection Screen
//

import SwiftUI

struct AvatarPickerView: View {
    @Binding var isPresented: Bool
    @ObservedObject var dataManager = DataManager.shared
    @State private var selectedIcon: String = "person.fill"
    @State private var selectedColor: String = "#7F5AF0"
    
    let avatarIcons = [
        "person.fill", "person.circle.fill", "star.fill", "heart.fill",
        "bolt.fill", "flame.fill", "sparkles", "moon.fill",
        "sun.max.fill", "cloud.fill", "leaf.fill", "drop.fill"
    ]
    
    let avatarColors = [
        "#7F5AF0", "#2CB67D", "#FF6B6B", "#4ECDC4",
        "#FFE66D", "#FF8C42", "#A8DADC", "#457B9D",
        "#E63946", "#F72585", "#7209B7", "#3A0CA3"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        VStack(spacing: 16) {
                            Text("Preview")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                            
                            ZStack {
                                Circle()
                                    .fill(Color(hex: selectedColor))
                                    .frame(width: 120, height: 120)
                                    .shadow(color: Color(hex: selectedColor).opacity(0.4), radius: 20, x: 0, y: 10)
                                
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Icons
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose Icon")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                                ForEach(avatarIcons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIcon == icon ? Color.appPrimary.opacity(0.2) : Color.white)
                                                .frame(width: 70, height: 70)
                                            
                                            Image(systemName: icon)
                                                .font(.system(size: 32))
                                                .foregroundColor(selectedIcon == icon ? Color.appPrimary : .gray)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Colors
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose Color")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                                ForEach(avatarColors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: color))
                                                .frame(width: 60, height: 60)
                                            
                                            if selectedColor == color {
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 4)
                                                    .frame(width: 60, height: 60)
                                                
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Save Button
                        Button(action: saveAvatar) {
                            Text("Save Avatar")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.appPrimary)
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Choose Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            selectedIcon = dataManager.user.avatarIcon
            selectedColor = dataManager.user.avatarColor
        }
    }
    
    private func saveAvatar() {
        dataManager.user.avatarIcon = selectedIcon
        dataManager.user.avatarColor = selectedColor
        dataManager.saveUser()
        isPresented = false
    }
}

