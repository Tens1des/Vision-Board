//
//  HomeView.swift
//  BoardNote
//
//  Main Home Screen
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var searchText = ""
    @State private var showingNewBoardSheet = false
    @State private var selectedBoard: Board?
    
    var filteredBoards: [Board] {
        if searchText.isEmpty {
            return dataManager.boards
        }
        return dataManager.boards.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search Bar
                    searchBar
                    
                    // Boards List
                    if filteredBoards.isEmpty {
                        emptyStateView
                    } else {
                        boardsList
                    }
                }
                
                // Floating Add Button
                floatingAddButton
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingNewBoardSheet) {
                NewBoardSheet(isPresented: $showingNewBoardSheet)
            }
            .fullScreenCover(item: $selectedBoard) { board in
                BoardDetailView(board: board)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 20) {
            // User Profile Section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStrings.hello)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(dataManager.user.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // User Avatar
                Button(action: {
                    // Profile action - could open profile sheet
                }) {
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
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: dataManager.user.avatarIcon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            // Title and Subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStrings.myBoards)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                Text(LocalizedStrings.createAndOrganize)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search boards...", text: $searchText)
                .font(.system(size: 16))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Boards List
    private var boardsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredBoards) { board in
                    BoardCard(
                        board: board,
                        onTap: {
                            selectedBoard = board
                        },
                        onDelete: {
                            deleteBoard(board)
                        }
                    )
                }
                .onDelete(perform: deleteBoardsAtOffsets)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Delete Functions
    private func deleteBoard(_ board: Board) {
        withAnimation {
            dataManager.deleteBoard(board)
        }
    }
    
    private func deleteBoardsAtOffsets(at offsets: IndexSet) {
        withAnimation {
            offsets.forEach { index in
                let board = filteredBoards[index]
                dataManager.deleteBoard(board)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No boards yet")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
            
            Text("Create your first vision board\nand start visualizing your dreams")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text("Tap the + button to get started")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Floating Add Button
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showingNewBoardSheet = true }) {
                    ZStack {
                        // Gradient Circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "#4A90E2"), Color(hex: "#7F5AF0")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .blur(radius: 3)
                            .overlay(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "#4A90E2"), Color(hex: "#7F5AF0")]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                            )
                            .shadow(color: Color(hex: "#7F5AF0").opacity(0.3), radius: 15, x: 0, y: 8)
                        
                        // Plus Icon
                        Image(systemName: "plus")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                }
                .scaleEffect(1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingNewBoardSheet)
                .padding(.trailing, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Board Card
struct BoardCard: View {
    let board: Board
    let onTap: () -> Void
    let onDelete: () -> Void
    @ObservedObject var dataManager = DataManager.shared
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail (left side)
            ZStack {
                // Show thumbnail if available
                if let thumbnailData = board.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Fallback: Show custom icon or default
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.appPrimary.opacity(0.6), Color.appSecondary.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Group {
                                if let iconPhotoData = board.iconPhotoData, let uiImage = UIImage(data: iconPhotoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } else if let emoji = board.iconEmoji, !emoji.isEmpty {
                                    Text(emoji)
                                        .font(.system(size: 40))
                                } else {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        )
                }
            }
            
            // Content (center)
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(board.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                // Details
                HStack(spacing: 4) {
                    Text("\(board.elements.count) \(LocalizedStrings.elements)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(board.createdAt.daysAgo())
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Menu button (right side)
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .alert(LocalizedStrings.deleteBoard, isPresented: $showingDeleteAlert) {
            Button(LocalizedStrings.cancel, role: .cancel) { }
            Button(LocalizedStrings.delete, role: .destructive) {
                onDelete()
            }
        } message: {
            Text(String(format: LocalizedStrings.deleteBoardConfirm, board.title))
        }
    }
}

// MARK: - New Board Sheet
struct NewBoardSheet: View {
    @Binding var isPresented: Bool
    @State private var boardTitle = ""
    @State private var boardYear = ""
    @State private var selectedColor = "#7F5AF0"
    @State private var selectedEmoji = "🎯"
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var showingPhotoPicker = false
    @ObservedObject var dataManager = DataManager.shared
    
    let gradientColors = [
        "#7F5AF0", "#4A90E2", "#2CB67D", "#FF6B6B", 
        "#4ECDC4", "#FFE66D", "#FF8C42", "#A8DADC"
    ]
    
    let emojiOptions = ["🎯", "💡", "🚀", "🌟", "❤️", "⭐", "🔥", "💎", "🎨", "🏠", "🌍", "💰"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.appBackground,
                        Color(hex: selectedColor).opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with Customizable Icon
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: selectedColor),
                                                Color(hex: selectedColor).opacity(0.7)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color(hex: selectedColor).opacity(0.3), radius: 20, x: 0, y: 10)
                                
                                // Show emoji or photo
                                if let photoData = selectedPhotoData, let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                } else {
                                    Text(selectedEmoji)
                                        .font(.system(size: 36))
                                }
                            }
                            
                            Text("Create New Vision Board")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Bring your dreams to life")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Board Title
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "textformat")
                                        .foregroundColor(Color(hex: selectedColor))
                                        .frame(width: 20)
                                    
                                    Text("Board Title")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                TextField("My Dream Board", text: $boardTitle)
                                    .font(.system(size: 18))
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            }
                            
                            // Year
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(hex: selectedColor))
                                        .frame(width: 20)
                                    
                                    Text("Year (Optional)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                TextField("2025", text: $boardYear)
                                    .font(.system(size: 18))
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                                    .keyboardType(.numberPad)
                            }
                            
                            // Board Icon Selection
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "face.smiling")
                                        .foregroundColor(Color(hex: selectedColor))
                                        .frame(width: 20)
                                    
                                    Text("Board Icon")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                // Emoji Selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Choose Emoji")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                                        ForEach(emojiOptions, id: \.self) { emoji in
                                            Button(action: { 
                                                selectedEmoji = emoji
                                                selectedPhotoData = nil // Clear photo when emoji selected
                                            }) {
                                                Text(emoji)
                                                    .font(.system(size: 32))
                                                    .frame(width: 50, height: 50)
                                                    .background(
                                                        Circle()
                                                            .fill(Color.white)
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(selectedEmoji == emoji ? Color(hex: selectedColor) : Color.clear, lineWidth: 3)
                                                            )
                                                    )
                                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                            }
                                        }
                                    }
                                }
                                
                                // Photo Selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Or Choose Photo")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Button(action: { showingPhotoPicker = true }) {
                                        HStack {
                                            Image(systemName: "photo")
                                                .font(.system(size: 20))
                                            Text("Select from Gallery")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                        .foregroundColor(Color(hex: selectedColor))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    }
                                    
                                    if selectedPhotoData != nil {
                                        Button(action: { 
                                            selectedPhotoData = nil
                                            selectedPhoto = nil
                                        }) {
                                            Text("Remove Photo")
                                                .font(.system(size: 14))
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            
                            // Color Selection
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "paintpalette")
                                        .foregroundColor(Color(hex: selectedColor))
                                        .frame(width: 20)
                                    
                                    Text("Theme Color")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                                    ForEach(gradientColors, id: \.self) { color in
                                        Button(action: { selectedColor = color }) {
                                            Circle()
                                                .fill(Color(hex: color))
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: selectedColor == color ? 4 : 0)
                                                )
                                                .shadow(color: Color(hex: color).opacity(0.3), radius: 8, x: 0, y: 4)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Floating Create Button
                VStack {
                    Spacer()
                    
                    Button(action: createBoard) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                            
                            Text("Create Board")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: selectedColor),
                                    Color(hex: selectedColor).opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(hex: selectedColor).opacity(0.4), radius: 20, x: 0, y: 10)
                        .scaleEffect(boardTitle.isEmpty ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3), value: boardTitle.isEmpty)
                    }
                    .disabled(boardTitle.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedPhotoData = data
                        selectedEmoji = "" // Clear emoji when photo selected
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Custom Header
                VStack {
                    HStack {
                        Button(action: { isPresented = false }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 44, height: 44)
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    
                    Spacer()
                }
            )
        }
    }
    
    private func createBoard() {
        let newBoard = Board(
            title: boardTitle, 
            year: boardYear.isEmpty ? nil : boardYear,
            iconEmoji: selectedPhotoData == nil ? selectedEmoji : nil,
            iconPhotoData: selectedPhotoData
        )
        dataManager.addBoard(newBoard)
        isPresented = false
    }
}

