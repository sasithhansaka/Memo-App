//
//  MemoryService.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-16.
//



import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

enum MemoryServiceError: LocalizedError {
    case userNotSignedIn
    case noPhotos
    case imageEncodingFailed
    case photosTooLarge

    var errorDescription: String? {
        switch self {
        case .userNotSignedIn:
            return "Please sign in before saving a memory."
        case .noPhotos:
            return "Please add at least one photo."
        case .imageEncodingFailed:
            return "A photo could not be processed. Please try another photo."
        case .photosTooLarge:
            return """
            These photos are too large to save together in Firestore.
            Remove some photos and try again.
            """
        }
    }
}

final class MemoryService {
    private let db = Firestore.firestore()

    
    private let maxEncodedPhotoBytes = 600_000

    func saveMemory(
        title: String,
        description: String,
        category: String,
        memoryDate: Date,
        photos: [UIImage],
        ocrText: String,
        latitude: Double,
        longitude: Double,
        placeName: String?
    ) async throws -> String {
        guard let currentUser = Auth.auth().currentUser else {
            throw MemoryServiceError.userNotSignedIn
        }

        guard !photos.isEmpty else {
            throw MemoryServiceError.noPhotos
        }

        let encodedPhotos = try photos.map { image -> String in
            guard let base64 = MemoryImageEncoder.encode(image) else {
                throw MemoryServiceError.imageEncodingFailed
            }

            return base64
        }

        let encodedSize = encodedPhotos.reduce(0) {
            $0 + $1.utf8.count
        }

        guard encodedSize <= maxEncodedPhotoBytes else {
            throw MemoryServiceError.photosTooLarge
        }

        let document = db.collection("memories").document()
        let now = Date()

        let memory = Memory(
            id: document.documentID,
            userId: currentUser.uid,
            title: title.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            description: description.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty ? nil : description.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            category: category,
            memoryDate: memoryDate,
            photoBase64: encodedPhotos,
            coverPhotoBase64: encodedPhotos[0],
            ocrtext: ocrText.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty ? nil : ocrText,
            longitude: longitude,
            latitude: latitude,
            placeName: placeName,
            createdAt: now,
            updatedAt: now,
            isDeleted: false
        )

        try await document.setData(memory.firestoreData)

        return document.documentID
    }
}
