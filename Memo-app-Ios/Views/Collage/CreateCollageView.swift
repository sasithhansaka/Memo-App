//
//  CreateCollageView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-26.
//

import Foundation
import SwiftUI
import UIKit


struct CreateCollageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CollageViewModel
    @State private var showShareSheet = false
    init(memory: Memory) {
        _viewModel = StateObject(
            wrappedValue: CollageViewModel(
                memory: memory
            )
        )
    }
    
    
    var body: some View {
        ZStack {
            MemoMapTheme.background
                .ignoresSafeArea()
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 22)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        CollageTemplatePickerView(
                            viewModel: viewModel
                        )
                        previewSection
                        // Background customization below preview.
                        backgroundSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showShareSheet) {
            if let image = viewModel.exportedImage {
                CollageActivityView(image: image)
                    .ignoresSafeArea()
            }
        }
        .alert(
            "Collage",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(
                        .system(size: 17, weight: .semibold)
                    )
                    .foregroundStyle(MemoMapTheme.black)
                    .frame(width: 42, height: 42)
                    .background(MemoMapTheme.White)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Go back")
            Text("Create Collage")
                .font(MemoFont.dmSansSemiBold(21))
                .foregroundStyle(MemoMapTheme.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 4)
            Button {
                if viewModel.exportedImage != nil {
                    showShareSheet = true
                } else {
                    viewModel.updatePreview()
                    if viewModel.exportedImage != nil {
                        showShareSheet = true
                    }
                }
            } label: {
                Image(
                    systemName: "square.and.arrow.up"
                )
                .font(
                    .system(size: 19, weight: .semibold)
                )
                .foregroundStyle(MemoMapTheme.White)
                .frame(width: 44, height: 44)
                .background(MemoMapTheme.green)
                .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Share collage")
            .disabled(viewModel.collagePhotos.isEmpty)
            .opacity(
                viewModel.collagePhotos.isEmpty ? 0.45 : 1
            )
        }
    }
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
//            Text("Preview")
//                .font(MemoFont.dmSansSemiBold(18))
//                .foregroundStyle(MemoMapTheme.black)
            if let image = viewModel.exportedImage {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                        )
                        .shadow(
                            color: .black.opacity(0.10),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                }
                .aspectRatio(4.0 / 5.0, contentMode: .fit)
            } else if viewModel.collagePhotos.isEmpty {
                ContentUnavailableView(
                    "No Photos Available",
                    systemImage: "photo",
                    description: Text(
                        "Add a photo to this memory before creating a collage."
                    )
                )
                .frame(height: 300)
            } else {
                ProgressView("Creating preview…")
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
            }
        }
    }
    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Background color")
                .font(MemoFont.dmSansSemiBold(18))
                .foregroundStyle(MemoMapTheme.black)
            HStack(spacing: 0) {
                ForEach(
                    CollageBackground.allCases
                ) { style in
                    Button {
                        viewModel.selectBackground(style)
                    } label: {
                        VStack(spacing: 7) {
                            Circle()
                                .fill(style.color)
                                .frame(
                                    width: 42,
                                    height: 42
                                )
                                .overlay {
                                    Circle()
                                        .stroke(
                                            MemoMapTheme.inputBorder,
                                            lineWidth: 1
                                        )
                                }
                                .overlay {
                                    if viewModel.backgroundStyle == style {
                                        Image(systemName: "checkmark")
                                            .font(
                                                .system(
                                                    size: 14,
                                                    weight: .bold
                                                )
                                            )
                                            .foregroundStyle(
                                                style == .dark
                                                    ? .white
                                                    : MemoMapTheme.black
                                            )
                                    }
                                }
                            Text(style.title)
                                .font(
                                    MemoFont.dmSansRegular(11)
                                )
                                .foregroundStyle(
                                    MemoMapTheme.black
                                )
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        "\(style.title) background"
                    )
                    .accessibilityAddTraits(
                        viewModel.backgroundStyle == style
                            ? .isSelected
                            : []
                    )
                }
            }
        }
        .padding(16)
        .background(MemoMapTheme.White)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .stroke(
                MemoMapTheme.inputBorder,
                lineWidth: 0.8
            )
        }
    }
}
