//
//  ElementEditorView.swift
//  BoardNote
//
//  Advanced Element Editor with Gestures
//

import SwiftUI

struct EditableElement: View {
    @Binding var element: BoardElement
    let isSelected: Bool
    let onSelect: () -> Void
    let onUpdate: () -> Void
    
    @State private var lastScale: CGFloat = 1.0
    @State private var lastRotation: Angle = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var basePosition: CGPoint = .zero
    
    var body: some View {
        ZStack {
            ElementView(element: element, isSelected: isSelected)
            
            if isSelected {
                // Selection Handles
                selectionHandles
            }
        }
        .position(element.position)
        .highPriorityGesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    if basePosition == .zero {
                        basePosition = element.position
                    }
                    let newPosition = CGPoint(
                        x: basePosition.x + value.translation.width,
                        y: basePosition.y + value.translation.height
                    )
                    if element.position != newPosition {
                        element.position = newPosition
                    }
                }
                .onEnded { _ in
                    basePosition = .zero
                    onUpdate()
                }
        )
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    let delta = value / lastScale
                    lastScale = value
                    element.scale *= delta
                }
                .onEnded { _ in
                    lastScale = 1.0
                    onUpdate()
                }
        )
        .simultaneousGesture(
            RotationGesture()
                .onChanged { value in
                    let delta = value - lastRotation
                    lastRotation = value
                    element.rotation += delta.degrees
                }
                .onEnded { _ in
                    lastRotation = .zero
                    onUpdate()
                }
        )
        .onTapGesture {
            onSelect()
        }
    }
    
    private var selectionHandles: some View {
        EmptyView()
    }
}

// MARK: - Element Context Menu
struct ElementContextMenu: View {
    let element: BoardElement
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onBringForward: () -> Void
    let onSendBackward: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            menuButton(icon: "pencil", title: "Edit", action: onEdit)
            Divider()
            menuButton(icon: "doc.on.doc", title: "Duplicate", action: onDuplicate)
            Divider()
            menuButton(icon: "arrow.up.to.line", title: "Bring Forward", action: onBringForward)
            Divider()
            menuButton(icon: "arrow.down.to.line", title: "Send Backward", action: onSendBackward)
            Divider()
            menuButton(icon: "trash", title: "Delete", action: onDelete, color: .red)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .frame(width: 200)
    }
    
    private func menuButton(icon: String, title: String, action: @escaping () -> Void, color: Color = .black) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Text Element Editor
struct TextElementEditor: View {
    @Binding var element: BoardElement
    @Binding var isPresented: Bool
    @State private var editedText: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextEditor(text: $editedText)
                        .font(.system(size: 18))
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .frame(height: 200)
                    
                    Spacer()
                    
                    Button(action: saveText) {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.appPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Edit Text")
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
            editedText = element.text ?? ""
        }
    }
    
    private func saveText() {
        element.text = editedText
        element.updatedAt = Date()
        isPresented = false
    }
}

// MARK: - Color Picker for Elements
struct ElementColorPicker: View {
    @Binding var element: BoardElement
    @Binding var isPresented: Bool
    
    let colors = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A",
        "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2",
        "#F8B739", "#52BE80", "#5DADE2", "#EC7063"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Color Preview
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: element.color ?? "#FF6B6B"))
                        .frame(height: 150)
                        .shadow(color: Color(hex: element.color ?? "#FF6B6B").opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    // Color Grid
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: { element.color = color }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: color))
                                        .frame(height: 70)
                                    
                                    if element.color == color {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Text("Done")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.appPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Choose Color")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

