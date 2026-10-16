//
//  MemoryImageEncoder.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-16.
//

import Foundation
import UIKit

enum MemoryImageEncoder {
    static func encode(
        _ image: UIImage,
        maxDimension: CGFloat = 700,
        quality: CGFloat = 0.35
    ) -> String? {
        let size = image.size

        guard size.width > 0, size.height > 0 else {
            return nil
        }

        let longestSide = max(size.width, size.height)
        let scale = min(1, maxDimension / longestSide)

        let resizedSize = CGSize(
            width: max(1, size.width * scale),
            height: max(1, size.height * scale)
        )

        let renderer = UIGraphicsImageRenderer(size: resizedSize)

        let resizedImage = renderer.image { _ in
            image.draw(
                in: CGRect(origin: .zero, size: resizedSize)
            )
        }

        guard let data = resizedImage.jpegData(
            compressionQuality: quality
        ) else {
            return nil
        }

        return data.base64EncodedString()
    }

    static func decode(_ base64: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }

        return UIImage(data: data)
    }
}
