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
    
    func deletememory(id: String) async throws{
        try await db
            .collection("memories")
            .document(id)
            .updateData(["isDeleted": true])
    }
    
    
    func updateNotifyDate(memoryID: String, date: Date = Date()) async throws {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            throw MemoryServiceError.userNotSigned
        }

        let document = db.collection("memories").document(memoryID)
        let snapshot = try await document.getDocument()

        guard
            let data = snapshot.data(),
            data["userID"] as? String == userID,
            (data["isDeleted"] as? Bool ?? false) == false
        else {
            throw NSError(
                domain: "MemoryService",
                code: 403,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "This memory is unavailable or does not belong to you."
                ]
            )
        }

        try await document.updateData([
            "notify_date": Timestamp(date: date)
        ])
        
    }
    
    func getMemory(id: String) async throws -> Memory {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw MemoryServiceError.userNotSigned
        }

        let document = db.collection("memories").document(id)
        let snapshot = try await document.getDocument()

        guard
            snapshot.exists,
            let data = snapshot.data(),
            let documentUserID = data["userID"] as? String,
            documentUserID == userID,
            (data["isDeleted"] as? Bool ?? false) == false,
            let title = data["title"] as? String,
            let category = data["category"] as? String,
            let coverPhoto = data["coverPhotoBase64"] as? String
        else {
            throw NSError(
                domain: "MemoryService",
                code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "This memory could not be found or is unavailable."
                ]
            )
        }

        let memoryDate = (data["memoryDate"] as? Timestamp)?.dateValue()
            ?? Date()

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
            ?? memoryDate

        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
            ?? createdAt

        let notifyDate = (data["notify_date"] as? Timestamp)?.dateValue()

        return Memory(
            id: snapshot.documentID,
            userId: documentUserID,
            title: title,
            description: data["description"] as? String,
            category: category,
            memoryDate: memoryDate,
            photoBase64: data["photosBase64"] as? [String],
            coverPhotoBase64: coverPhoto,
            ocrtext: data["ocrText"] as? String,
            longitude: data["longitude"] as? Double ?? 0,
            latitude: data["latitude"] as? Double ?? 0,
            placeName: data["placeName"] as? String,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: false,
            notifyDate: notifyDate
        )
    }

    func updateMemory(
        id: String,
        title: String,
        description: String,
        category: String,
        memoryDate: Date,
        photos: [UIImage],
        ocrText: String,
        latitude: Double,
        longitude: Double,
        placeName: String
    ) async throws {

        guard let userID = Auth.auth().currentUser?.uid else {
            throw MemoryServiceError.userNotSigned
        }

        guard !photos.isEmpty else {
            throw MemoryServiceError.noPhotos
        }

        let encodedPhotos = try photos.map { image -> String in
            guard let base64 = MemoryImageEncoder.encode(image) else {
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

        let document = db.collection("memories").document(id)
        let snapshot = try await document.getDocument()

        guard
            snapshot.exists,
            let data = snapshot.data(),
            data["userID"] as? String == userID,
            (data["isDeleted"] as? Bool ?? false) == false
        else {
            throw NSError(
                domain: "MemoryService",
                code: 403,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "You cannot update this memory."
                ]
            )
        }

        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedDescription = description.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedOCR = ocrText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedPlaceName = placeName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        try await document.updateData([
            "title": trimmedTitle,
            "description": trimmedDescription.isEmpty
                ? NSNull() as Any
                : trimmedDescription,
            "category": category,
            "memoryDate": Timestamp(date: memoryDate),
            "photosBase64": encodedPhotos,
            "coverPhotoBase64": encodedPhotos[0],
            "ocrText": trimmedOCR.isEmpty
                ? NSNull() as Any
                : trimmedOCR,
            "latitude": latitude,
            "longitude": longitude,
            "placeName": trimmedPlaceName,
            "updatedAt": Timestamp(date: Date())
        ])
    }

}

