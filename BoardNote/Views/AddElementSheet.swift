//
//  AddElementSheet.swift
//  BoardNote
//
//  Add Element Selection Screen
//

import SwiftUI
import PhotosUI

struct AddElementSheet: View {
    @Binding var board: Board
    @Binding var isPresented: Bool
    @ObservedObject var dataManager = DataManager.shared
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingTextEditor = false
    @State private var showingColorPicker = false
    @State private var selectedElementType: ElementType?
    
    let elementTypes: [(type: ElementType, color: String, icon: String)] = [
        (.photo, "#4A90E2", "photo"),
        (.text, "#2ECC71", "text.alignleft"),
        (.sticker, "#F39C12", "square.on.square"),
        (.shape, "#E74C3C", "circle"),
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Add Element")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    Text("Select element type to add to your board")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    // Element Types Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(elementTypes, id: \.type) { item in
                            elementTypeCard(type: item.type, color: item.color, icon: item.icon)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Stickers Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Stickers")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(stickerEmojis, id: \.self) { emoji in
                                    Button(action: { addEmojiSticker(emoji) }) {
                                        Text(emoji)
                                            .font(.system(size: 40))
                                            .frame(width: 70, height: 70)
                                            .background(Color.white)
                                            .cornerRadius(16)
                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Shape Backgrounds Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Shapes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(shapeColors, id: \.self) { color in
                                    Button(action: { addShape(color: color) }) {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 3)
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .photosPicker(isPresented: Binding(
            get: { selectedElementType == .photo },
            set: { if !$0 { selectedElementType = nil } }
        ), selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    addPhotoElement(data: data)
                }
            }
        }
        .sheet(isPresented: $showingTextEditor) {
            TextEditorSheet(board: $board, isPresented: $showingTextEditor)
        }
    }
    
    // MARK: - Element Type Card
    private func elementTypeCard(type: ElementType, color: String, icon: String) -> some View {
        Button(action: { handleElementTypeSelection(type) }) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: color).opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    // Show last used sticker for sticker type
                    if type == .sticker, let lastSticker = dataManager.user.lastUsedSticker {
                        Text(lastSticker)
                            .font(.system(size: 36))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: color))
                    }
                }
                
                Text(type.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - Data
    private let stickerEmojis = ["⭐", "❤️", "🎯", "💡", "🚀", "🌟", "🔥", "💎"]
    private let shapeColors = ["#7F5AF0", "#2CB67D", "#FF6B6B", "#4ECDC4", "#FFE66D", "#FF8C42", "#A8DADC", "#457B9D"]
    
    // MARK: - Actions
    private func handleElementTypeSelection(_ type: ElementType) {
        switch type {
        case .photo:
            selectedElementType = .photo
        case .text:
            showingTextEditor = true
        case .sticker:
            // Add last used sticker or default
            if let lastSticker = dataManager.user.lastUsedSticker {
                addEmojiSticker(lastSticker)
            } else {
                // Default to first emoji if no last used
                addEmojiSticker(stickerEmojis.first ?? "⭐")
            }
        case .shape:
            addShape(color: shapeColors.first!)
        default:
            break
        }
    }
    
    private func getCenterPosition() -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        // Canvas is 3x larger, so center is at 1.5x screen dimensions
        return CGPoint(x: screenWidth * 1.5, y: screenHeight * 1.5)
    }
    
    private func addPhotoElement(data: Data) {
        var element = BoardElement(type: .photo, position: getCenterPosition())
        element.imageData = data
        board.elements.append(element)
        dataManager.updateBoard(board)
        dataManager.checkAchievement("photo_master")
        isPresented = false
    }
    
    private func addEmojiSticker(_ emoji: String) {
        var element = BoardElement(type: .text, position: getCenterPosition())
        element.text = emoji
        element.size = CGSize(width: 120, height: 120)
        element.color = nil // No background
        board.elements.append(element)
        
        // Save as last used sticker
        dataManager.user.lastUsedSticker = emoji
        dataManager.saveUser()
        
        dataManager.updateBoard(board)
        isPresented = false
    }
    
    private func addShape(color: String) {
        var element = BoardElement(type: .shape, position: getCenterPosition())
        element.color = color
        element.shapeType = .circle
        board.elements.append(element)
        dataManager.updateBoard(board)
        isPresented = false
    }
}

// MARK: - Text Editor Sheet
struct TextEditorSheet: View {
    @Binding var board: Board
    @Binding var isPresented: Bool
    @State private var text = ""
    @ObservedObject var dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextEditor(text: $text)
                        .font(.system(size: 18))
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .frame(height: 200)
                    
                    Spacer()
                    
                    Button(action: addTextElement) {
                        Text("Add Text")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(text.isEmpty ? Color.gray : Color.appPrimary)
                            .cornerRadius(12)
                    }
                    .disabled(text.isEmpty)
                }
                .padding(20)
            }
            .navigationTitle("Add Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func addTextElement() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerPosition = CGPoint(x: screenWidth * 1.5, y: screenHeight * 1.5)
        
        var element = BoardElement(type: .text, position: centerPosition)
        element.text = text
        element.color = "#FFFFFF" // White background for text notes
        board.elements.append(element)
        dataManager.updateBoard(board)
        dataManager.checkAchievement("text_guru")
        isPresented = false
    }
}

