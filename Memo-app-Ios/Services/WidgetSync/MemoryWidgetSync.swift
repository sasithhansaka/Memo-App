//
//  MemoryWidgetSync.swift
//  Memo-app-Ios
//

import Foundation
import WidgetKit
import FirebaseFirestore
import UIKit

@MainActor
final class MemoryWidgetSync {

    static let shared = MemoryWidgetSync()

    private let memoryService = MemoryService()
    private var memoryListener: ListenerRegistration?

    private init() {}


    func start() {

        guard memoryListener == nil else {
            return
        }

        memoryListener = memoryService.getTimlineMemories(
            onChange: { memories in

                print("Widget sync received memories:", memories.count)

                let widgetMemories = memories
                    .filter { !$0.isDeleted }
                    .sorted {
                        $0.memoryDate > $1.memoryDate
                    }
                    .prefix(5)
                    .map { memory in

                        let resizedPhoto = self.makeWidgetImageBase64(
                            from: memory.coverPhotoBase64
                        )

                        print(
                            "Prepared widget photo:",
                            memory.id,
                            "Base64 length:",
                            resizedPhoto.count
                        )

                        return MemoryWidgetItem(
                            id: memory.id,
                            title: memory.title,
                            memoryDate: memory.memoryDate,
                            placeName: memory.placeName,
                            coverPhotoBase64: resizedPhoto
                        )
                    }

                MemoryWidgetStorage.save(
                    Array(widgetMemories)
                )

                print(
                    "Saved memories to widget:",
                    widgetMemories.count
                )

                // Refresh the widget timeline.
                WidgetCenter.shared.reloadTimelines(
                    ofKind: "MemoAppWidget"
                )
            },
            onError: { error in

                print(
                    "Widget memory sync failed:",
                    error.localizedDescription
                )
            }
        )
    }


    func stop() {

        memoryListener?.remove()
        memoryListener = nil
    }


    private func makeWidgetImageBase64(
        from base64: String,
        maxDimension: CGFloat = 200
    ) -> String {
        guard
            let data = Data(base64Encoded: base64),
            let image = UIImage(data: data)
        else {
            print("Widget image decoding failed.")
            return ""
        }

        let originalSize = image.size

        guard
            originalSize.width > 0,
            originalSize.height > 0
        else {
            print("Invalid widget image dimensions.")
            return ""
        }

        let scale = min(
            maxDimension / originalSize.width,
            maxDimension / originalSize.height,
            1.0
        )

        let newSize = CGSize(
            width: max(1, originalSize.width * scale),
            height: max(1, originalSize.height * scale)
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)

        let resizedImage = renderer.image { _ in
            image.draw(
                in: CGRect(
                    origin: .zero,
                    size: newSize
                )
            )
        }

        guard let jpegData = resizedImage.jpegData(
            compressionQuality: 0.50
        ) else {
            print("Widget JPEG conversion failed.")
            return ""
        }

        print(
            "Widget image resized:",
            "\(Int(newSize.width)) x \(Int(newSize.height))",
            "JPEG bytes:",
            jpegData.count
        )

        return jpegData.base64EncodedString()
    }
}
