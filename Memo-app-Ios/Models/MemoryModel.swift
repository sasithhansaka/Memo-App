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
    
    var notifyDate: Date?

    

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
            "isDeleted": isDeleted,
            "notify_date": notifyDate.map {
               Timestamp(date: $0)
           } as Any? ?? NSNull()
        ]
    }
    
    init?(document: QueryDocumentSnapshot) {
          
         let data = document.data()

          guard
              let userId = data["userID"] as? String,
              let title = data["title"] as? String,
              let category = data["category"] as? String,
              let coverPhotoBase64 = data["coverPhotoBase64"] as? String
          else {
              return nil
          }

          self.id = document.documentID
          self.userId = userId
          self.title = title
          self.description = data["description"] as? String
          self.category = category

          if let timestamp = data["memoryDate"] as? Timestamp {
              self.memoryDate = timestamp.dateValue()
          } else {
              self.memoryDate = Date()
          }

          self.photoBase64 = data["photosBase64"] as? [String]
          self.coverPhotoBase64 = coverPhotoBase64
          self.ocrtext = data["ocrText"] as? String

          self.latitude = data["latitude"] as? Double ?? 0
          self.longitude = data["longitude"] as? Double ?? 0
          self.placeName = data["placeName"] as? String

          if let timestamp = data["createdAt"] as? Timestamp {
              self.createdAt = timestamp.dateValue()
          } else {
              self.createdAt = self.memoryDate
          }

          if let timestamp = data["updatedAt"] as? Timestamp {
              self.updatedAt = timestamp.dateValue()
          } else {
              self.updatedAt = self.createdAt
          }

          self.isDeleted = data["isDeleted"] as? Bool ?? false
        
            if let timestamp = data["notify_date"] as? Timestamp {
               self.notifyDate = timestamp.dateValue()
           } else {
               self.notifyDate = nil
           }
      }
    
    init(
        id: String,
        userId: String,
        title: String,
        description: String?,
        category: String,
        memoryDate: Date,
        photoBase64: [String]?,
        coverPhotoBase64: String,
        ocrtext: String?,
        longitude: Double,
        latitude: Double,
        placeName: String?,
        createdAt: Date,
        updatedAt: Date,
        isDeleted: Bool,
        notifyDate: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.category = category
        self.memoryDate = memoryDate
        self.photoBase64 = photoBase64
        self.coverPhotoBase64 = coverPhotoBase64
        self.ocrtext = ocrtext
        self.longitude = longitude
        self.latitude = latitude
        self.placeName = placeName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
        self.notifyDate = notifyDate
    }

}
