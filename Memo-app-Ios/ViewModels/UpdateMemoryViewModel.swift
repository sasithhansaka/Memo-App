//
//  UpdateMemoryViewModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-28.
//

import Foundation
import SwiftUI
import PhotosUI
import UIKit
import Combine

@MainActor
final class UpdateMemoryViewModel: ObservableObject {


    @Published var title = ""
    @Published var description = ""
    @Published var category = ""
    @Published var memoryDate = Date()
    @Published var photos: [UIImage] = []
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    @Published var ocrText = ""
    @Published var photoOCRTexts: [String] = []
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var placeName: String?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var isLoadingPhotos = false
    @Published var isReadingOCR = false
    @Published var hasLoadedMemory = false
    @Published var errorMessage: String?
    @Published var titleError: String?
    @Published var categoryError: String?
    @Published var photosError: String?
    @Published var locationError: String?
    @Published var showSuccessAlert = false

    private let memoryService: MemoryService
    private let maximumTitleLength = 80
    private let maximumPhotoCount = 10

    private var memoryID: String?

    let categories = [
        "Travels",
        "Family",
        "University & Education",
        "Friends",
        "Other"
    ]

    init(memoryService: MemoryService = MemoryService()) {
        self.memoryService = memoryService
    }

    // MARK: - OCR Tags

    var ocrTags: [String] {
        ocrText
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
    }

    // MARK: - Retrieve Existing Memory

    func loadMemory(id: String) async {

        guard !isLoading, !hasLoadedMemory else {
            return
        }

        memoryID = id
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let memory = try await memoryService.getMemory(id: id)

            // Populate the form only after retrieval succeeds.
            title = memory.title
            description = memory.description ?? ""
            category = memory.category
            memoryDate = memory.memoryDate

            latitude = memory.latitude
            longitude = memory.longitude
            placeName = memory.placeName

            let storedPhotos = memory.photoBase64
                ?? [memory.coverPhotoBase64]

            let decodedPhotos = storedPhotos.compactMap {
                MemoryImageEncoder.decode($0)
            }

            // Older documents may have only a cover photo.
            if decodedPhotos.isEmpty,
               let coverPhoto = MemoryImageEncoder.decode(
                   memory.coverPhotoBase64
               ) {
                photos = [coverPhoto]
            } else {
                photos = decodedPhotos
            }

            guard !photos.isEmpty else {
                photosError = "The saved photos could not be loaded."
                errorMessage = photosError
                return
            }

            // Rebuild OCR for each loaded photo so removing a photo
            // also removes that photo's extracted text.
            isReadingOCR = true
            photoOCRTexts = []

            for photo in photos {
                let text = await MemoryOCRService.recognizeText(in: photo)

                photoOCRTexts.append(
                    text.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                )
            }

            isReadingOCR = false
            rebuildOCRText()

            // If OCR could not extract text, retain the saved OCR.
            if ocrText.isEmpty {
                ocrText = memory.ocrtext ?? ""
            }

            hasLoadedMemory = true
            titleError = nil
            categoryError = nil
            photosError = nil
            locationError = nil

        } catch {
            isReadingOCR = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Field Updates

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

        self.placeName = String(cleanName.prefix(200))
        self.latitude = latitude
        self.longitude = longitude

        locationError = nil
        errorMessage = nil
    }

    // MARK: - Speech-to-Text

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

    // MARK: - Add Photos

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

    // MARK: - Remove Photos

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

    // MARK: - Validation

    private func validateFields() -> Bool {

        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        titleError = trimmedTitle.isEmpty
            ? "Please enter a memory title."
            : nil

        categoryError = categories.contains(category)
            ? nil
            : "Please select a category."

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

    // MARK: - Save Changes

    func updateMemory() async {

        guard !isSaving else {
            return
        }

        guard hasLoadedMemory, let memoryID else {
            errorMessage = "Load the memory before updating it."
            return
        }

        errorMessage = nil

        guard validateFields() else {
            return
        }

        guard
            let latitude,
            let longitude,
            let placeName
        else {
            locationError = "Please select a location for this memory."
            return
        }

        isSaving = true

        defer {
            isSaving = false
        }

        do {
            try await memoryService.updateMemory(
                id: memoryID,
                title: title.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                description: description.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
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
