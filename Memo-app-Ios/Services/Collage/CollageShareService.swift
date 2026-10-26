//
//  CollageShareService.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-26.
//

import Foundation
import SwiftUI
import UIKit
struct CollageActivityView: UIViewControllerRepresentable {
    let image: UIImage
    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
    }
    func updateUIViewController(
        _ controller: UIActivityViewController,
        context: Context
    ) {
        // No updates required.
    }
}
