//
//  MemoryDetailViewModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-19.
//

import Foundation
import SwiftUI
import UIKit
import Combine


@MainActor
final class MemoryDetailViewModel: ObservableObject {
    @Published private(set) var memory: Memory
    @Published var selectedPhotoIndex = 0
    @Published private(set) var isDeleting = false
    @Published var deleteErrorMessage: String?
    @Published var showDeleteError = false
    
    private let memoryService = MemoryService()

    
    
    init(memory: Memory) {
        self.memory = memory
    }
    
    func deleteMemory() async -> Bool {
        guard !isDeleting else { return false }

        isDeleting = true
        deleteErrorMessage = nil

        do {
            try await memoryService.deletememory(id: memory.id)
            isDeleting = false
            return true
        } catch {
            deleteErrorMessage = error.localizedDescription
            showDeleteError = true
            isDeleting = false
            return false
        }
    }
    
    
    var photos: [UIImage] {
        let encodedPhotos = memory.photoBase64 ?? []
        
        let decodedPhotos = encodedPhotos.compactMap {
            MemoryImageEncoder.decode($0)
        }
        
        if !decodedPhotos.isEmpty {
            return decodedPhotos
        }
        
        if let cover = MemoryImageEncoder.decode(
            memory.coverPhotoBase64
        ) {
            return [cover]
        }
        
        return []
    }
    
    var locationText: String {
        guard let place = memory.placeName,
              !place.trimmingCharacters(
                in: .whitespacesAndNewlines
              ).isEmpty else {
            return "Location not added"
        }
        
        return place
    }
    
    var ocrTags: [String] {
           guard let text = memory.ocrtext,
                 !text.trimmingCharacters(
                   in: .whitespacesAndNewlines
                 ).isEmpty else {
               return []
           }

           let words = text
               .components(separatedBy: .newlines)
               .flatMap { $0.split(whereSeparator: \.isWhitespace) }
               .map { String($0).trimmingCharacters(in: .punctuationCharacters) }
               .filter { !$0.isEmpty }

           return Array(NSOrderedSet(array: words)) as? [String] ?? []
       }
    
    var categoryTag: String {
        "#" + memory.category.replacingOccurrences(
            of: " ",
            with: ""
        )
    }
}
