//
//  CollageRendererError.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-26.
//

import Foundation
import SwiftUI
import UIKit
enum CollageRendererError: LocalizedError {
    case noPhotos
    case renderingFailed
    var errorDescription: String? {
        switch self {
        case .noPhotos:
            return "This memory does not contain any usable photos."
        case .renderingFailed:
            return "The collage could not be created. Please try again."
        }
    }
}
@MainActor
enum CollageRenderer {
    static func render(
        photos: [UIImage],
        template: CollageTemplate,
        background: CollageBackground,
        memory: Memory
    ) throws -> UIImage {
        guard !photos.isEmpty else {
            throw CollageRendererError.noPhotos
        }
        // Portrait output: 4:5 ratio.
        let size = CGSize(
            width: 360,
            height: 450
        )
        let composition = CollageEditorView(
            photos: photos,
            template: template,
            background: background,
            memory: memory
        )
        .frame(
            width: size.width,
            height: size.height
        )
        .clipped()
        let renderer = ImageRenderer(
            content: composition
        )
        renderer.scale = 3
        renderer.proposedSize = ProposedViewSize(
            width: size.width,
            height: size.height
        )
        renderer.isOpaque = true
        guard let image = renderer.uiImage else {
            throw CollageRendererError.renderingFailed
        }
        return image
    }
}
