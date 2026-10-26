//
//  CollageViewModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-26.
//

import Foundation
import SwiftUI
import UIKit
import Combine



@MainActor
final class CollageViewModel: ObservableObject {
    let memory: Memory
    @Published var availablePhotos: [UIImage] = []
    @Published var selectedTemplate: CollageTemplate = .classicGrid
    @Published var backgroundStyle: CollageBackground = .cream
    @Published var exportedImage: UIImage?
    @Published var isExporting = false
    @Published var errorMessage: String?
    var collagePhotos: [UIImage] {
        Array(availablePhotos.prefix(4))
    }
    init(memory: Memory) {
        self.memory = memory
        loadPhotos()
        updatePreview()
    }
    private func loadPhotos() {
        var images: [UIImage] = []
        if let encodedPhotos = memory.photoBase64 {
            images = encodedPhotos.compactMap {
                MemoryImageEncoder.decode($0)
            }
        }
        if images.isEmpty,
           let cover = MemoryImageEncoder.decode(
                memory.coverPhotoBase64
           ) {
            images = [cover]
        }
        availablePhotos = images
    }
    func selectTemplate(_ template: CollageTemplate) {
        selectedTemplate = template
        updatePreview()
    }
    func selectBackground(_ background: CollageBackground) {
        backgroundStyle = background
        updatePreview()
    }
    func updatePreview() {
        guard !collagePhotos.isEmpty else {
            exportedImage = nil
            errorMessage = "This memory does not contain any usable photos."
            return
        }
        errorMessage = nil
        isExporting = true
        defer {
            isExporting = false
        }
        do {
            exportedImage = try CollageRenderer.render(
                photos: collagePhotos,
                template: selectedTemplate,
                background: backgroundStyle,
                memory: memory
            )
        } catch {
            exportedImage = nil
            errorMessage = error.localizedDescription
        }
    }
}

enum CollageBackground: String, CaseIterable, Identifiable {
    case cream
    case white
    case green
    case dark
    case pink
    case blue
    var id: String {
        rawValue
    }
    var title: String {
        switch self {
        case .cream: return "Cream"
        case .white: return "White"
        case .green: return "Sage"
        case .dark: return "Dark"
        case .pink: return "Pink"
        case .blue: return "Blue"
        }
    }
    var color: Color {
        switch self {
        case .cream:
            return Color(red: 0.97, green: 0.96, blue: 0.92)
        case .white:
            return .white
        case .green:
            return Color(red: 0.84, green: 0.89, blue: 0.82)
        case .dark:
            return Color(red: 0.10, green: 0.15, blue: 0.12)
        case .pink:
            return Color(red: 0.98, green: 0.87, blue: 0.88)
        case .blue:
            return Color(red: 0.84, green: 0.90, blue: 0.97)
        }
    }
}
