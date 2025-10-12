//
//  BoardNoteApp.swift
//  BoardNote
//
//  Created by Рома Котов on 11.10.2025.
//

import SwiftUI

@main
struct BoardNoteApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
