//
//  BoardDetailView.swift
//  BoardNote
//
//  Board Detail Screen with Elements
//

import SwiftUI
import PhotosUI

struct BoardDetailView: View {
    let board: Board
    @ObservedObject var dataManager = DataManager.shared
    @State private var currentBoard: Board
    @State private var showingAddElement = false
    @State private var selectedElement: BoardElement?
    @State private var isDrawingArrow = false
    @State private var showingElementContextMenu = false
    @State private var showingTextEditor = false
    @State private var showingColorPicker = false
    @State private var canvasScale: CGFloat = 1.0
    @State private var lastCanvasScale: CGFloat = 1.0
    @State private var canvasOffset: CGSize = .zero
    @State private var lastCanvasOffset: CGSize = .zero
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingQuickTextEditor = false
    @State private var showingPhotoPicker = false
    @Environment(\.presentationMode) var presentationMode
    
    init(board: Board) {
        self.board = board
        _currentBoard = State(initialValue: board)
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if isDrawingArrow {
                ArrowDrawingMode(board: $currentBoard, isDrawingArrow: $isDrawingArrow)
            } else {
                // Canvas
                GeometryReader { geometry in
                    ZStack {
                        // Grid background
                        if dataManager.settings.showGrid {
                            gridBackground
                        }
                        
                        // Elements
                        ForEach(currentBoard.elements) { element in
                            EditableElement(
                                element: Binding(
                                    get: { element },
                                    set: { updateElement($0) }
                                ),
                                isSelected: selectedElement?.id == element.id,
                                onSelect: { selectElement(element) },
                                onUpdate: { saveBoard() }
                            )
                        }
                        
                        // Empty state hint
                        if currentBoard.elements.isEmpty {
                            emptyBoardHint
                        }
                    }
                    .frame(width: geometry.size.width * 3, height: geometry.size.height * 3)
                    .background(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedElement = nil
                            }
                    )
                    .scaleEffect(canvasScale)
                    .offset(x: canvasOffset.width, y: canvasOffset.height)
                    .gesture(
                        DragGesture(minimumDistance: 3)
                            .onChanged { value in
                                if !currentBoard.elements.isEmpty && selectedElement == nil {
                                    canvasOffset = CGSize(
                                        width: lastCanvasOffset.width + value.translation.width,
                                        height: lastCanvasOffset.height + value.translation.height
                                    )
                                }
                            }
                            .onEnded { _ in
                                lastCanvasOffset = canvasOffset
                            }
                    )
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if !currentBoard.elements.isEmpty {
                                    canvasScale = lastCanvasScale * value
                                }
                            }
                            .onEnded { _ in
                                lastCanvasScale = canvasScale
                            }
                    )
                }
                
                // Toolbar
                VStack {
                    topToolbar
                    Spacer()
                    
                    // Floating Add Button (Top Right)
                    floatingAddButton
                }
                
                // Bottom Toolbar (Fixed at bottom)
                VStack {
                    Spacer()
                    bottomToolbar
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddElement) {
            AddElementSheet(board: $currentBoard, isPresented: $showingAddElement)
        }
        .sheet(isPresented: $showingTextEditor) {
            TextElementEditor(
                element: Binding(
                    get: { selectedElement ?? BoardElement(type: .text) },
                    set: { selectedElement = $0 }
                ),
                isPresented: $showingTextEditor
            )
        }
        .sheet(isPresented: $showingColorPicker) {
            ElementColorPicker(
                element: Binding(
                    get: { selectedElement ?? BoardElement(type: .sticker) },
                    set: { selectedElement = $0 }
                ),
                isPresented: $showingColorPicker
            )
        }
        .sheet(isPresented: $showingQuickTextEditor) {
            QuickTextEditor(board: $currentBoard, isPresented: $showingQuickTextEditor)
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    addPhotoElement(data: data)
                }
            }
        }
        .onAppear {
            loadBoard()
            centerCanvas()
        }
        .onDisappear {
            saveBoard()
        }
    }
    
    // MARK: - Empty Board Hint
    private var emptyBoardHint: some View {
        VStack(spacing: 20) {
            Image(systemName: "plus.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Add your first element")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Tap the + button below to start creating your vision board")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Grid Background
    private var gridBackground: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 20
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Vertical lines
                for x in stride(from: 0, through: width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                
                // Horizontal lines
                for y in stride(from: 0, through: height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        }
    }
    
    // MARK: - Top Toolbar
    private var topToolbar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            Text(currentBoard.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Menu {
                Button(action: { dataManager.settings.showGrid.toggle() }) {
                    Label(dataManager.settings.showGrid ? "Hide Grid" : "Show Grid", systemImage: "grid")
                }
                
                if selectedElement != nil {
                    Divider()
                    
                    Button(action: { showingTextEditor = true }) {
                        Label("Edit Text", systemImage: "pencil")
                    }
                    
                    Button(action: { showingColorPicker = true }) {
                        Label("Change Color", systemImage: "paintpalette")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: deleteSelectedElement) {
                        Label("Delete Element", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 100)
    }
    
    // MARK: - Bottom Toolbar
    private var bottomToolbar: some View {
        HStack(spacing: 16) {
            // Movement Button (Active)
            Button(action: { 
                // Movement mode is default - no special action needed
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 20, weight: .medium))
                    Text(LocalizedStrings.movement)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.appPrimary)
                .cornerRadius(12)
            }
            
            // Text Button
            Button(action: { addTextElement() }) {
                VStack(spacing: 6) {
                    Text("T")
                        .font(.system(size: 20, weight: .bold))
                    Text(LocalizedStrings.text)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(12)
            }
            
            // Photo Button
            Button(action: { addPhotoElement() }) {
                VStack(spacing: 6) {
                    Image(systemName: "photo")
                        .font(.system(size: 20, weight: .medium))
                    Text(LocalizedStrings.photo)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(12)
            }
            
            // Shape Button
            Button(action: { addShapeElement() }) {
                VStack(spacing: 6) {
                    Image(systemName: "square")
                        .font(.system(size: 20, weight: .medium))
                    Text(LocalizedStrings.figure)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(12)
            }
            
            // Arrow Button
            Button(action: { isDrawingArrow = true }) {
                VStack(spacing: 6) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .medium))
                    Text(LocalizedStrings.arrow)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 34)
        .padding(.top, 12)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
    
    // MARK: - Floating Add Button
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showingAddElement = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.5, green: 0.35, blue: 0.94),
                                        Color(red: 0.95, green: 0.39, blue: 0.69)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 150)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func loadBoard() {
        if let savedBoard = dataManager.boards.first(where: { $0.id == board.id }) {
            currentBoard = savedBoard
        }
    }
    
    private func centerCanvas() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        // Elements spawn at (1.5 * screen), we want that to be in center of viewport
        // So we need to offset: center - spawnPoint = 0.5 * screen - 1.5 * screen = -1.0 * screen
        let offsetX = -screenWidth * 1.0
        let offsetY = -screenHeight * 1.0
        canvasOffset = CGSize(width: offsetX, height: offsetY)
        lastCanvasOffset = canvasOffset
    }
    
    private func selectElement(_ element: BoardElement) {
        selectedElement = element
    }
    
    private func updateElement(_ element: BoardElement) {
        if let index = currentBoard.elements.firstIndex(where: { $0.id == element.id }) {
            currentBoard.elements[index] = element
            selectedElement = element
        }
    }
    
    private func deleteSelectedElement() {
        if let element = selectedElement {
            currentBoard.elements.removeAll { $0.id == element.id }
            selectedElement = nil
            saveBoard()
            dataManager.trackAction("delete_element")
        }
    }
    
    private func saveBoard() {
        dataManager.updateBoard(currentBoard)
    }
    
    // MARK: - Quick Actions
    private func addPhotoElement() {
        showingPhotoPicker = true
    }
    
    private func addShapeElement() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        var newElement = BoardElement(
            type: .shape,
            position: CGPoint(x: screenWidth * 1.5, y: screenHeight * 1.5)
        )
        newElement.shapeType = .circle
        newElement.color = "#4ECDC4"
        
        currentBoard.elements.append(newElement)
        selectedElement = newElement
        saveBoard()
        dataManager.trackAction("add_shape")
    }
    
    private func addPhotoElement(data: Data) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerPosition = CGPoint(x: screenWidth * 1.5, y: screenHeight * 1.5)
        
        var element = BoardElement(type: .photo, position: centerPosition)
        element.imageData = data
        currentBoard.elements.append(element)
        saveBoard()
        dataManager.checkAchievement("photo_master")
    }
    
    private func addTextElement() {
        showingQuickTextEditor = true
    }
}

// MARK: - Quick Text Editor
struct QuickTextEditor: View {
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
                        .frame(height: 150)
                    
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
            .navigationTitle("Quick Text")
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

// MARK: - Element View
struct ElementView: View {
    let element: BoardElement
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            switch element.type {
            case .photo:
                photoElement
            case .text:
                textElement
            case .sticker:
                stickerElement
            case .shape:
                shapeElement
            case .arrow:
                arrowElement
            }
            
            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.appPrimary, lineWidth: 3)
                    .frame(width: element.size.width + 10, height: element.size.height + 10)
            }
        }
        .position(element.position)
        .rotationEffect(.degrees(element.rotation))
        .scaleEffect(element.scale)
    }
    
    private var photoElement: some View {
        Group {
            if let imageData = element.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: element.size.width, height: element.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: element.size.width, height: element.size.height)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    private var textElement: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let text = element.text {
                Text(text)
                    .font(.system(size: element.size.width > 100 ? 60 : 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(12)
        .frame(width: element.size.width, height: element.size.height, alignment: .center)
        .background(element.color != nil ? Color.white : Color.clear)
        .cornerRadius(12)
        .shadow(color: element.color != nil ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
    }
    
    private var stickerElement: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: element.color ?? "#FF6B6B"))
            .frame(width: element.size.width, height: element.size.height)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    private var shapeElement: some View {
        Group {
            switch element.shapeType {
            case .circle:
                Circle()
                    .fill(Color(hex: element.color ?? "#4ECDC4"))
                    .frame(width: element.size.width, height: element.size.height)
            case .square:
                Rectangle()
                    .fill(Color(hex: element.color ?? "#4ECDC4"))
                    .frame(width: element.size.width, height: element.size.height)
            case .triangle:
                Triangle()
                    .fill(Color(hex: element.color ?? "#4ECDC4"))
                    .frame(width: element.size.width, height: element.size.height)
            case .none:
                Circle()
                    .fill(Color(hex: element.color ?? "#4ECDC4"))
                    .frame(width: element.size.width, height: element.size.height)
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    private var arrowElement: some View {
        Group {
            if let start = element.startPoint, let end = element.endPoint {
                Path { path in
                    path.move(to: start)
                    path.addLine(to: end)
                }
                .stroke(Color(hex: element.arrowColor ?? "#95E1D3"), lineWidth: element.lineWidth ?? 3)
            }
        }
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

