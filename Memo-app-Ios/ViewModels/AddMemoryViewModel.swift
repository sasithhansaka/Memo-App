//
//  AddMemoryViewModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-19.
//


import Foundation
import SwiftUI
import PhotosUI
import UIKit
import Combine

@MainActor
final class AddMemoryViewModel: ObservableObject {
  
    @Published  var title = ""
    @Published  var description = ""
    @Published  var category = ""
    @Published  var memoryDate = Date()
    @Published  var photos: [UIImage] = []
    @Published  var selectedPhotoItems: [PhotosPickerItem] = []
    @Published  var ocrText = ""
    @Published  var photoOCRTexts: [String] = []
    @Published  var latitude = 0.0
    @Published  var longitude = 0.0
    @Published  var placeName: String?
    @Published  var isSaving = false
    @Published  var isLoadingPhotos = false
    @Published  var isReadingOCR = false
    @Published  var errorMessage: String?
    @Published  var showSuccessAlert = false

    private let memoryService: MemoryService
    
     let categories = [
        "Travels",
        "Family",
        "University & Education",
        "Friends",
        "Other"
    ]
  
    init(memoryService: MemoryService) {
        self.memoryService = memoryService
    }

    convenience init() {
        self.init(memoryService: MemoryService())
    }

    var ocrTags: [String] {
        ocrText
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
    }

     func updateTitle(_ newValue: String) {
        title = String(newValue.prefix(80))
        errorMessage = nil
    }
    
    func updateDescription(_ newValue: String) {
        description = newValue
        errorMessage = nil
    }

    func selectCategory(_ value: String) {
        category = value
        errorMessage = nil
    }


    func selectLocation(
        name: String,
        latitude: Double,
        longitude: Double
    ) {
        placeName = name
        self.latitude = latitude
        self.longitude = longitude
        errorMessage = nil
    }

    func updateDescriptionWithSpeech(
        baseDescription: String,
        spokenText: String
    ) {
        let base = baseDescription.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let spoken = spokenText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if spoken.isEmpty {
            description = baseDescription
        } else if base.isEmpty {
            description = spoken
        } else {
            description = base + " " + spoken
        }
    }




    func loadSelectedPhotos(
        _ items: [PhotosPickerItem]
    ) async {
        guard !items.isEmpty, !isLoadingPhotos else {
            return
        }

        isLoadingPhotos = true
        errorMessage = nil

        let startingIndex = photos.count

        defer {
            isLoadingPhotos = false
            selectedPhotoItems = []
        }

        for item in items {
            guard photos.count < 10 else {
                break
            }

            do {
                guard
                    let data = try await item.loadTransferable(
                        type: Data.self
                    ),
                    let image = UIImage(data: data)
                else {
                    continue
                }

                photos.append(image)
                photoOCRTexts.append("")
            } catch {
                continue
            }
        }

        guard photos.count > startingIndex else {
            errorMessage =
                "Could not load the selected photos. Please try again."
            return
        }

        isReadingOCR = true
        defer { isReadingOCR = false }

        for index in startingIndex..<photos.count {
            let extractedText = await MemoryOCRService.recognizeText(
                in: photos[index]
            )

            photoOCRTexts[index] = extractedText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        }

        rebuildOCRText()
    }


    func removePhoto(at index: Int) {
        guard photos.indices.contains(index) else {
            return
        }

        photos.remove(at: index)

        if photoOCRTexts.indices.contains(index) {
            photoOCRTexts.remove(at: index)
        }

        rebuildOCRText()
    }


     private func rebuildOCRText() {
        ocrText = photoOCRTexts
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }

    func saveMemory() async {
        guard !isSaving else {
            return
        }

        errorMessage = nil

        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedTitle.isEmpty else {
            errorMessage = "Please enter a memory title."
            return
        }

        guard !category.isEmpty else {
            errorMessage = "Please select a category."
            return
        }

        guard !photos.isEmpty else {
            errorMessage = "Please add at least one photo."
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await memoryService.saveMemory(
                title: trimmedTitle,
                description: description,
                category: category,
                memoryDate: memoryDate,
                photos: photos,
                ocrText: ocrText,
                latitude: latitude,
                longitude: longitude,
                placeName: placeName
            )

            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


