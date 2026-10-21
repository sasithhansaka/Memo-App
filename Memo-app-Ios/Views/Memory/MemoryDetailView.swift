//
//  MemoryDetailView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-19.
//
import Foundation
import SwiftUI
import UIKit

struct MemoryDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: MemoryDetailViewModel
    @State private var showDeleteConfirmation = false

    var onUpdate: (() -> Void)? = nil
    var onDeleted: (() -> Void)? = nil

    init(
        memory: Memory,
        onUpdate: (() -> Void)? = nil,
        onDeleted: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: MemoryDetailViewModel(memory: memory)
        )
        self.onUpdate = onUpdate
        self.onDeleted = onDeleted
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {

                MemoMapTheme.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        photoHeader(width: geometry.size.width)

                        memoryContent
                    }
                    .frame(maxWidth: .infinity)
                }
                .ignoresSafeArea(edges: .top)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .alert(
            "Unable to Delete Memory",
            isPresented: $viewModel.showDeleteError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.deleteErrorMessage ?? "Please try again.")
        }
    }

    private func photoHeader(width: CGFloat) -> some View {
        ZStack(alignment: .top) {
            if viewModel.photos.isEmpty {
                Rectangle()
                    .fill(MemoMapTheme.inputBorder.opacity(0.3))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 36))
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                    }
                    .frame(height: 390)
            } else {
                TabView(selection: $viewModel.selectedPhotoIndex) {
                    ForEach(
                        Array(viewModel.photos.enumerated()),
                        id: \.offset
                    ) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: 390)
                            .clipped()
                            .tag(index)
                    }
                }
                .frame(width: width, height: 390)
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.95))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Go back")

                Spacer()

                Button {
                    showDeleteConfirmation = true
                } label: {
                    if viewModel.isDeleting {
                        ProgressView()
                            .tint(.black)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.95))
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "trash")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.95))
                            .clipShape(Circle())
                    }
                }
                .disabled(viewModel.isDeleting)
                .confirmationDialog(
                    "Delete this memory?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Memory", role: .destructive) {
                        Task {
                            let deleted = await viewModel.deleteMemory()

                            if deleted {
                                onDeleted?()
                                dismiss()
                            }
                        }
                    }

                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to delete this memory?")
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 65)

            if viewModel.photos.count > 1 {
                VStack {
                    Spacer()

                    HStack(spacing: 7) {
                        ForEach(viewModel.photos.indices, id: \.self) { index in
                            Circle()
                                .fill(
                                    viewModel.selectedPhotoIndex == index
                                        ? Color.white
                                        : Color.white.opacity(0.5)
                                )
                                .frame(width: 7, height: 7)
                        }
                    }
                    .padding(.bottom, 22)
                }
                .frame(height: 390)
                .allowsHitTesting(false)
            }
        }
        .frame(width: width, height: 390)
    }

    private var memoryContent: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text(viewModel.memory.title)
                .font(MemoFont.dmSansBold(30))
                .foregroundStyle(MemoMapTheme.black)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 8) {
//                Text(viewModel.formattedDate)

                Text("•")

                Text(viewModel.locationText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(MemoFont.dmSansMedium(15))
            .foregroundStyle(MemoMapTheme.Textsecondary)
            .padding(.top, 8)

            if let description = viewModel.memory.description,
               !description.trimmingCharacters(
                    in: .whitespacesAndNewlines
               ).isEmpty {
                Text(description)
                    .font(MemoFont.dmSansRegular(19))
                    .foregroundStyle(MemoMapTheme.black)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
                    .padding(.top, 30)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Text(viewModel.categoryTag)

                    ForEach(viewModel.ocrTags, id: \.self) { tag in
                        Text("#\(tag)")
                    }
                }
                .font(MemoFont.dmSansMedium(14))
                .foregroundStyle(MemoMapTheme.Textsecondary)
            }
            .padding(.top, 28)
        }
        .padding(.horizontal, 28)
        .padding(.top, 40)
        .padding(.bottom, 40)
        .frame(maxWidth: 520, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 30,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 30
            )
            .fill(MemoMapTheme.background)
        }
        .padding(.top, -28)
    }
}

#Preview {
    NavigationStack {
        Text("Pass a real Memory instance to preview MemoryDetailView.")
    }
}

