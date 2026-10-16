//
//  MemoryModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-16.
//

import Foundation
import FirebaseFirestore

struct Memory: Identifiable {
    
    var id : String
    var userId: String
    var title: String
    var description: String?
    var category: String
    var memoryDate: Date
    
    var photoBase64: [String]?
    var coverPhotoBase64 : String
    
    var ocrtext : String?
    var longitude: Double
    
    var latitude: Double
    var placeName: String?
    
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    

    var firestoreData: [String: Any] {
        [
            "userID": userId,
            "title": title,
            "description": description as Any? ?? NSNull(),
            "category": category,
            "memoryDate": Timestamp(date: memoryDate),
            "photosBase64": photoBase64 as Any? ?? NSNull(),
            "coverPhotoBase64": coverPhotoBase64,
            "ocrText": ocrtext as Any? ?? NSNull(),
            "latitude": latitude,
            "longitude": longitude,
            "placeName": placeName as Any? ?? NSNull(),
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
            "isDeleted": isDeleted
        ]
    }

}
