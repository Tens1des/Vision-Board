//
//  ArrowDrawingView.swift
//  BoardNote
//
//  Arrow Drawing Tool
//

import SwiftUI

struct ArrowDrawingMode: View {
    @Binding var board: Board
    @Binding var isDrawingArrow: Bool
    @State private var arrowStart: CGPoint?
    @State private var arrowEnd: CGPoint?
    @State private var currentArrow: BoardElement?
    @State private var selectedColor: String = "#7F5AF0"
    @State private var lineWidth: Double = 3
    
    let colors = ["#7F5AF0", "#2CB67D", "#FF6B6B", "#4ECDC4", "#FFE66D", "#FF8C42"]
    
    var body: some View {
        ZStack {
            // Drawing Canvas
            GeometryReader { geometry in
                ZStack {
                    // Temporary arrow while drawing
                    if let start = arrowStart, let end = arrowEnd {
                        ArrowShape(start: start, end: end, lineWidth: lineWidth)
                            .stroke(Color(hex: selectedColor), lineWidth: lineWidth)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if arrowStart == nil {
                                arrowStart = value.location
                            }
                            arrowEnd = value.location
                        }
                        .onEnded { value in
                            finishArrow()
                        }
                )
            }
            
            // Toolbar
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    // Color Selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Button(action: { selectedColor = color }) {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 4 : 0)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Line Width
                    VStack(spacing: 8) {
                        Text("Line Width: \(Int(lineWidth))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                        
                        Slider(value: $lineWidth, in: 1...10, step: 1)
                            .accentColor(Color.appPrimary)
                            .padding(.horizontal, 20)
                    }
                    
                    // Done Button
                    Button(action: { isDrawingArrow = false }) {
                        Text("Done Drawing")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.appPrimary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
        }
    }
    
    private func finishArrow() {
        guard let start = arrowStart, let end = arrowEnd else { return }
        
        var arrow = BoardElement(type: .arrow, position: start)
        arrow.startPoint = start
        arrow.endPoint = end
        arrow.arrowColor = selectedColor
        arrow.lineWidth = lineWidth
        
        board.elements.append(arrow)
        DataManager.shared.updateBoard(board)
        DataManager.shared.checkAchievement("connector")
        DataManager.shared.checkAchievement("link_master")
        
        // Reset for next arrow
        arrowStart = nil
        arrowEnd = nil
    }
}

// MARK: - Arrow Shape
struct ArrowShape: Shape {
    let start: CGPoint
    let end: CGPoint
    let lineWidth: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Line
        path.move(to: start)
        path.addLine(to: end)
        
        // Arrow head
        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowLength: CGFloat = 15
        let arrowAngle: CGFloat = .pi / 6
        
        let arrowPoint1 = CGPoint(
            x: end.x - arrowLength * cos(angle - arrowAngle),
            y: end.y - arrowLength * sin(angle - arrowAngle)
        )
        
        let arrowPoint2 = CGPoint(
            x: end.x - arrowLength * cos(angle + arrowAngle),
            y: end.y - arrowLength * sin(angle + arrowAngle)
        )
        
        path.move(to: end)
        path.addLine(to: arrowPoint1)
        path.move(to: end)
        path.addLine(to: arrowPoint2)
        
        return path
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

