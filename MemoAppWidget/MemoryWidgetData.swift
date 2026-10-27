//
//  MemoryWidgetData.swift
//  MemoAppWidgetExtension
//
//  Created by student3 on 2026-10-27.
//

import Foundation

struct MemoryWidgetItem: Codable, Identifiable {
    let id: String
    let title: String
    let memoryDate: Date
    let placeName: String?
    let coverPhotoBase64: String

    init(
        id: String,
        title: String,
        memoryDate: Date,
        placeName: String?,
        coverPhotoBase64: String
    ) {
        self.id = id
        self.title = title
        self.memoryDate = memoryDate
        self.placeName = placeName
        self.coverPhotoBase64 = coverPhotoBase64
    }
}

enum MemoryWidgetStorage {
    static let appGroupID = "group.sasith.memomap"
    static let storageKey = "savedWidgetMemories"

    static func save(_ memories: [MemoryWidgetItem]) {
        guard let defaults = UserDefaults(
            suiteName: appGroupID
        ) else {
            return
        }

        do {
            let data = try JSONEncoder().encode(memories)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to save widget memories:", error)
        }
    }

    static func load() -> [MemoryWidgetItem] {
        guard
            let defaults = UserDefaults(
                suiteName: appGroupID
            ),
            let data = defaults.data(forKey: storageKey)
        else {
            return []
        }

        do {
            return try JSONDecoder().decode(
                [MemoryWidgetItem].self,
                from: data
            )
        } catch {
            print("Failed to load widget memories:", error)
            return []
        }
    }
}
