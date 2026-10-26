//
//  CollageModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-26.
//

import Foundation
import SwiftUI

enum CollageTemplate: String, CaseIterable, Identifiable {
    case classicGrid
    case memoryStory
    case filmStrip
    case scrapbook
    case travelJournal
    var id: String { rawValue }
    var title: String {
        switch self {
        case .classicGrid: return "Classic Grid"
        case .memoryStory: return "Memory Story"
        case .filmStrip: return "Film Strip"
        case .scrapbook: return "Scrapbook"
        case .travelJournal: return "Travel Journal"
        }
    }
    var subtitle: String {
        switch self {
        case .classicGrid: return "Clean and balanced"
        case .memoryStory: return "One moment, many memories"
        case .filmStrip: return "A cinematic look"
        case .scrapbook: return "A personal keepsake"
        case .travelJournal: return "Memories from everywhere"
        }
    }
    var symbol: String {
        switch self {
        case .classicGrid: return "square.grid.2x2"
        case .memoryStory: return "photo.on.rectangle"
        case .filmStrip: return "film"
        case .scrapbook: return "heart.text.square"
        case .travelJournal: return "map"
        }
    }
    var minimumPhotos: Int {
        switch self {
        case .classicGrid: return 2
        case .memoryStory: return 2
        case .filmStrip: return 2
        case .scrapbook: return 1
        case .travelJournal: return 2
        }
    }
    var maximumPhotos: Int {
        switch self {
        case .classicGrid: return 4
        case .memoryStory: return 4
        case .filmStrip: return 5
        case .scrapbook: return 4
        case .travelJournal: return 5
        }
    }
}
