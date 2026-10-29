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
    
    @Published var title = ""
    @Published var description = ""
    @Published var category = ""
    @Published var memoryDate = Date()
    @Published var photos: [UIImage] = []
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    @Published var ocrText = ""
    @Published var photoOCRTexts: [String] = []
    @Published var latitude : Double?
    @Published var longitude : Double?
    @Published var placeName: String?
    @Published var locationError: String?
    @Published var isSaving = false
    @Published var isLoadingPhotos = false
    @Published var isReadingOCR = false
    @Published var titleError: String?
    @Published var categoryError: String?
    @Published var photosError: String?
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    private let memoryService: MemoryService
    private let maximumTitleLength = 80
    private let maximumPhotoCount = 10
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
        title = String(newValue.prefix(maximumTitleLength))
        titleError = nil
    }
    func updateDescription(_ newValue: String) {
        description = newValue
    }
    func selectCategory(_ value: String) {
        guard categories.contains(value) else {
            categoryError = "Please select a valid category."
            return
        }
        category = value
        categoryError = nil
    }
    
    
    func selectLocation(
        name: String,
        latitude: Double,
        longitude: Double
    ) {
        guard
            latitude.isFinite,
            longitude.isFinite,
            (-90.0...90.0).contains(latitude),
            (-180.0...180.0).contains(longitude)
        else {
            locationError = "The selected location is invalid."
            return
        }

        let cleanName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty else {
            locationError = "Please select a valid place."
            return
        }

        placeName = String(cleanName.prefix(200))
        self.latitude = latitude
        self.longitude = longitude

        locationError = nil
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
        guard photos.count < maximumPhotoCount else {
            photosError = "You can add up to 10 photos."
            selectedPhotoItems = []
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
            guard photos.count < maximumPhotoCount else {
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
                // Continue processing other selected photos.
                continue
            }
        }
        guard photos.count > startingIndex else {
            photosError =
                "Could not load the selected photos. Please try again."
            return
        }
        photosError = nil
        isReadingOCR = true
        defer {
            isReadingOCR = false
        }
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
        photosError = photos.isEmpty
            ? "Please add at least one photo."
            : nil
        rebuildOCRText()
    }
    private func rebuildOCRText() {
        ocrText = photoOCRTexts
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }
    @discardableResult
    private func validateFields() -> Bool {
        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        if trimmedTitle.isEmpty {
            titleError = "Please enter a memory title."
        } else {
            titleError = nil
        }
        if !categories.contains(category) {
            categoryError = "Please select a category."
        } else {
            categoryError = nil
        }
        if photos.isEmpty {
            photosError = "Please add at least one photo."
        } else if photos.count > maximumPhotoCount {
            photosError = "You can add a maximum of 10 photos."
        } else {
            photosError = nil
        }
        
        if latitude == nil || longitude == nil || placeName == nil {
               locationError = "Please select a location for this memory."
           } else {
               locationError = nil
           }

        
        
        return titleError == nil
            && categoryError == nil
            && photosError == nil
           && locationError == nil
    }
    
    func saveMemory() async {
        guard !isSaving else {
            return
        }
        errorMessage = nil
        guard validateFields() else {
            return
        }

        guard
            let latitude = latitude,
            let longitude = longitude,
            let placeName = placeName
        else {
            locationError = "Please select a location for this memory."
            return
        }
        
        
        isSaving = true
        defer {
            isSaving = false
        }
        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedDescription = description.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        do {
            _ = try await memoryService.saveMemory(
                title: trimmedTitle,
                description: trimmedDescription,
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
    
    func resetForm() {
        title = ""
        description = ""
        category = ""
        memoryDate = Date()
        photos = []
        selectedPhotoItems = []
        ocrText = ""
        photoOCRTexts = []
        latitude = nil
        longitude = nil
        placeName = nil
        titleError = nil
        categoryError = nil
        photosError = nil
        locationError = nil
        errorMessage = nil
    }
}
