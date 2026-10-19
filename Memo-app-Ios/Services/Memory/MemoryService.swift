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
    case userNotSigned
    case noPhotos
    case FailedimageEncoding
    case photosizeLarge

    var errorDescription: String? {
        switch self {
        case .userNotSigned:
            return "Please sign in before saving a memory."
        case .noPhotos:
            return "Please add at least one photo."
        case .FailedimageEncoding:
            return "A photo could not be processed."
        case .photosizeLarge:
            return "The selected photos exceed the 1 MB size limit."
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
        guard let currentUser = Auth.auth().currentUser
        else {
            throw MemoryServiceError.userNotSigned
        }

        guard !photos.isEmpty
        else {
            throw MemoryServiceError.noPhotos
        }

        let encodedPhotos = try photos.map { image -> String in
            guard let base64 = MemoryImageEncoder.encode(image)
            else {
                throw MemoryServiceError.FailedimageEncoding
            }
            return base64
        }

        let encodedSize = encodedPhotos.reduce(0) {
            $0 + $1.utf8.count
        }

        guard encodedSize <= maxEncodedPhotoBytes else {
            throw MemoryServiceError.photosizeLarge
        }

        let document = db.collection("memories").document()

        let now = Date()

        let OriginalTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let Originaldescription = description.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let OrginalOcrText = ocrText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let memory = Memory(
            id: document.documentID,
            userId: currentUser.uid,
            title: OriginalTitle,
            description: Originaldescription.isEmpty ? nil : Originaldescription,
            category: category,
            memoryDate: memoryDate,
            photoBase64: encodedPhotos,
            coverPhotoBase64: encodedPhotos[0],
            ocrtext: OrginalOcrText.isEmpty ? nil : OrginalOcrText,
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

    func getTimlineMemories(
        onChange: @escaping ([Memory]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration? {
        guard let userId = Auth.auth().currentUser?.uid else {
            onError(MemoryServiceError.userNotSigned)
            return nil
        }

        return db.collection("memories")
            .whereField("userID", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    onError(error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    onChange([])
                    return
                }

                let memories = documents.compactMap { document in
                    Memory(document: document)
                }
                .filter { !$0.isDeleted }
                .sorted { first, second in
                    if first.memoryDate != second.memoryDate {
                        return first.memoryDate > second.memoryDate
                    }

                    return first.createdAt > second.createdAt
                }

                onChange(memories)
            }
    }
}

