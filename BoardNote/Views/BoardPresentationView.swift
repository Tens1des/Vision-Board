//
//  BoardPresentationView.swift
//  BoardNote
//
//  Board Presentation Mode
//

import SwiftUI

struct BoardPresentationView: View {
    let board: Board
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            GeometryReader { geometry in
                ZStack {
                    // Elements
                    ForEach(board.elements) { element in
                        ElementView(element: element, isSelected: false)
                            .scaleEffect(element.scale)
                            .rotationEffect(.degrees(element.rotation))
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(scale)
                .offset(x: offset.width, y: offset.height)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 60)
                }
                Spacer()
            }
            
            // Title Overlay
            VStack {
                Spacer()
                VStack(spacing: 8) {
                    Text(board.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let year = board.year {
                        Text(year)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden()
        .onAppear {
            DataManager.shared.checkAchievement("inspiration")
        }
    }
}

