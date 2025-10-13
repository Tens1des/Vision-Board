//
//  BoardPreviewGenerator.swift
//  BoardNote
//
//  Board Thumbnail Generator
//

import SwiftUI
import UIKit

class BoardPreviewGenerator {
    static func generateThumbnail(for board: Board) -> Data? {
        let size = CGSize(width: 300, height: 400)
        
        // Use UIGraphics to render directly
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // Draw gradient background
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 0.6).cgColor,
                    UIColor(red: 0.50, green: 0.35, blue: 0.94, alpha: 0.6).cgColor
                ] as CFArray,
                locations: [0.0, 1.0]
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Draw board icon if available
            if let iconPhotoData = board.iconPhotoData,
               let iconImage = UIImage(data: iconPhotoData) {
                let iconSize: CGFloat = 80
                let iconX = (size.width - iconSize) / 2
                let iconY = (size.height - iconSize) / 2
                iconImage.draw(in: CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize))
            } else if let emoji = board.iconEmoji, !emoji.isEmpty {
                let font = UIFont.systemFont(ofSize: 60)
                let attributes: [NSAttributedString.Key: Any] = [.font: font]
                let emojiSize = (emoji as NSString).size(withAttributes: attributes)
                let emojiX = (size.width - emojiSize.width) / 2
                let emojiY = (size.height - emojiSize.height) / 2
                (emoji as NSString).draw(at: CGPoint(x: emojiX, y: emojiY), withAttributes: attributes)
            }
        }
        
        return image.jpegData(compressionQuality: 0.8)
    }
}

struct BoardPreviewView: View {
    let board: Board
    private let canvasSize: CGSize = CGSize(width: 300, height: 400)
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.appBackground, Color.white]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: canvasSize.width, height: canvasSize.height)
            
            // Elements
            ForEach(board.elements.prefix(8)) { element in
                ElementPreviewView(element: element)
                    .scaleEffect(0.3)
                    .position(
                        x: element.position.x * 0.3 + canvasSize.width * 0.5,
                        y: element.position.y * 0.3 + canvasSize.height * 0.5
                    )
            }
            
            // Title overlay
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .frame(height: 80)
                    .overlay(
                        VStack {
                            Text(board.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text("\(board.elements.count) elements")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    )
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }
}

struct ElementPreviewView: View {
    let element: BoardElement
    
    var body: some View {
        Group {
            switch element.type {
            case .photo:
                photoPreview
            case .text:
                textPreview
            case .sticker:
                stickerPreview
            case .shape:
                shapePreview
            case .arrow:
                arrowPreview
            }
        }
        .frame(width: element.size.width, height: element.size.height)
    }
    
    private var photoPreview: some View {
        Group {
            if let imageData = element.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    private var textPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let text = element.text {
                Text(text)
                    .font(.system(size: 8))
                    .foregroundColor(.black)
                    .lineLimit(3)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(6)
    }
    
    private var stickerPreview: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: element.color ?? "#FF6B6B"))
    }
    
    private var shapePreview: some View {
        Group {
            switch element.shapeType {
            case .circle:
                Circle()
                    .fill(Color(hex: element.color ?? "#4ECDC4"))
            case .square:
                Rectangle()
                    .fill(Color(hex: element.color ?? "#4ECDC4"))
            case .triangle:
                Triangle()
                    .fill(Color(hex: element.color ?? "#4ECDC4"))
            case .none:
                Circle()
                    .fill(Color(hex: element.color ?? "#4ECDC4"))
            }
        }
    }
    
    private var arrowPreview: some View {
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

