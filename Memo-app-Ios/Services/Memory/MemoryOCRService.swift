//
//  MemoryOCRService.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-16.
//

import Foundation

import UIKit
import Vision

enum MemoryOCRService {
    static func recognizeText(in image: UIImage) async -> String {
        guard let cgImage = image.cgImage else {
            return ""
        }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil,
                      let observations = request.results
                        as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let text = observations.compactMap {
                    $0.topCandidates(1).first?.string
                }

                continuation.resume(
                    returning: text.joined(separator: "\n")
                )
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            request.recognitionLanguages = ["en-US"]

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try VNImageRequestHandler(
                        cgImage: cgImage
                    ).perform([request])
                } catch {
                  
                }
            }
        }
    }
}
