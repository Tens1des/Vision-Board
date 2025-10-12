//
//  SettingsView.swift
//  BoardNote
//
//  Settings Screen
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var userName: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // User Name Section
                        VStack(spacing: 16) {
                            Text(LocalizedStrings.userSettings)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStrings.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                TextField(LocalizedStrings.yourName, text: $userName)
                                    .font(.system(size: 16))
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .onChange(of: userName) { newValue in
                                        dataManager.user.name = newValue
                                        dataManager.saveUser()
                                    }
                            }
                        }
                        
                        // Language Section
                        VStack(spacing: 16) {
                            Text(LocalizedStrings.language)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Language
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStrings.interfaceLanguage)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Picker(LocalizedStrings.language, selection: $dataManager.settings.language) {
                                    ForEach(AppLanguage.allCases, id: \.self) { language in
                                        Text(language.rawValue).tag(language)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: dataManager.settings.language) { _ in
                                    dataManager.saveSettings()
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Board Settings Section
                        VStack(spacing: 16) {
                            Text(LocalizedStrings.boardSettings)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Auto Save
                            HStack {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: "#4ECDC4").opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "arrow.down.doc")
                                            .foregroundColor(Color(hex: "#4ECDC4"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(LocalizedStrings.autoSave)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        Text(LocalizedStrings.saveChangesAutomatically)
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $dataManager.settings.autoSave)
                                    .labelsHidden()
                                    .onChange(of: dataManager.settings.autoSave) { _ in
                                        dataManager.saveSettings()
                                    }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            // Show Grid
                            HStack {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: "#FF8C42").opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "grid")
                                            .foregroundColor(Color(hex: "#FF8C42"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(LocalizedStrings.showGrid)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        Text(LocalizedStrings.displayGridOnCanvas)
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $dataManager.settings.showGrid)
                                    .labelsHidden()
                                    .onChange(of: dataManager.settings.showGrid) { _ in
                                        dataManager.saveSettings()
                                    }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Accessibility Section
                        VStack(spacing: 16) {
                            Text(LocalizedStrings.accessibility)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Font Size
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: "#FFE66D").opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "textformat.size")
                                            .foregroundColor(Color(hex: "#FFE66D"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(LocalizedStrings.textSize)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        Text(LocalizedStrings.adjustTextSize)
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Picker("Font Size", selection: $dataManager.settings.fontSize) {
                                    ForEach(FontSize.allCases, id: \.self) { size in
                                        Text(size.rawValue).tag(size)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: dataManager.settings.fontSize) { _ in
                                    dataManager.saveSettings()
                                }
                                
                                // Text Size Preview
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(LocalizedStrings.preview)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Small Text Size")
                                            .font(.system(size: 14 * dataManager.settings.fontSize.scale))
                                            .foregroundColor(.black)
                                        
                                        Text("Medium Text Size")
                                            .font(.system(size: 16 * dataManager.settings.fontSize.scale))
                                            .foregroundColor(.black)
                                        
                                        Text("Large Text Size")
                                            .font(.system(size: 18 * dataManager.settings.fontSize.scale, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    .padding(12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                    }
                    .padding(20)
                }
            }
            .navigationTitle(LocalizedStrings.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStrings.done) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            userName = dataManager.user.name
        }
    }
    
    // MARK: - Setting Row
    private func settingRow(icon: String, iconColor: String, title: String, subtitle: String) -> some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: iconColor).opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: iconColor))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

