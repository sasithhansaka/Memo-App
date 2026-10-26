//
//  CollagePreview.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-26.
//

import Foundation
import Foundation
import SwiftUI
import UIKit
struct CollagePreviewView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    var body: some View {
        ZStack {
            MemoMapTheme.background
                .ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(MemoMapTheme.black)
                            .frame(width: 44, height: 44)
                            .background(MemoMapTheme.White)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Text("Your Collage")
                        .font(MemoFont.dmSansSemiBold(20))
                        .foregroundStyle(MemoMapTheme.black)
                    Spacer()
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                Spacer(minLength: 0)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                    .padding(.horizontal, 18)
                    .shadow(
                        color: .black.opacity(0.12),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                Spacer(minLength: 0)
                Button {
                    showShareSheet = true
                } label: {
                    Label(
                        "Share Collage",
                        systemImage: "square.and.arrow.up"
                    )
                    .font(MemoFont.dmSansSemiBold(16))
                    .foregroundStyle(MemoMapTheme.White)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(MemoMapTheme.green)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 22)
                .padding(.bottom, 18)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showShareSheet) {
            CollageActivityView(image: image)
                .ignoresSafeArea()
        }
    }
}
