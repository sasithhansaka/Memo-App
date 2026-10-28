//
//  UpdateMemoryView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-28.
//

import Foundation
import SwiftUI
import PhotosUI
import UIKit

struct UpdateMemoryView: View {

    @Environment(\.dismiss) private var dismiss

    let memoryID: String

    @StateObject private var viewModel = UpdateMemoryViewModel()
    @StateObject private var speech = SpeechRecognitionService()

    @FocusState private var focusedField: InputField?

    @State private var showLocationPickerUpdate = false
    @State private var speechBaseDescription = ""

    private enum InputField: Hashable {
        case title
        case description
    }

    init(memoryID: String) {
        self.memoryID = memoryID
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && !viewModel.hasLoadedMemory {
                    loadingView
                } else if !viewModel.hasLoadedMemory {
                    loadErrorView
                } else {
                    formContent
                }
            }
            .background {
                MemoMapTheme.background
                    .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showLocationPickerUpdate) {
                    NavigationStack {
                        LocationPickerUpdate {
                            name, latitude, longitude in

                            viewModel.selectLocation(
                                name: name,
                                latitude: latitude,
                                longitude: longitude
                            )
                        }
                    }
                
            }
        
        
            .task {
                await viewModel.loadMemory(id: memoryID)
            }
            .onChange(of: viewModel.selectedPhotoItems) {
                _, newItems in

                guard !newItems.isEmpty else {
                    return
                }

                Task {
                    await viewModel.loadSelectedPhotos(newItems)
                }
            }
            .onChange(of: speech.recognizedText) {
                _, newText in

                guard speech.isRecording || !newText.isEmpty else {
                    return
                }

                viewModel.updateDescriptionWithSpeech(
                    baseDescription: speechBaseDescription,
                    spokenText: newText
                )
            }
            .alert(
                "Memory Updated",
                isPresented: $viewModel.showSuccessAlert
            ) {
                Button("Done") {
                    speech.stopRecording()
                    dismiss()
                }
            } message: {
                Text("Your memory was updated successfully.")
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(MemoMapTheme.green)
                .scaleEffect(1.2)

            Text("Loading memory...")
                .font(MemoFont.dmSansRegular(15))
                .foregroundStyle(MemoMapTheme.Textsecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadErrorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 38))
                .foregroundStyle(.red)

            Text("Unable to load memory")
                .font(MemoFont.dmSansSemiBold(20))
                .foregroundStyle(MemoMapTheme.black)

            Text(
                viewModel.errorMessage
                    ?? "Please try again."
            )
            .font(MemoFont.dmSansRegular(14))
            .foregroundStyle(MemoMapTheme.Textsecondary)
            .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.loadMemory(id: memoryID)
                }
            } label: {
                Text("Try Again")
                    .font(MemoFont.dmSansSemiBold(15))
                    .foregroundStyle(MemoMapTheme.White)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(MemoMapTheme.green)
                    .clipShape(Capsule())
            }
            .padding(.top, 6)

            Button("Go Back") {
                dismiss()
            }
            .font(MemoFont.dmSansMedium(14))
            .foregroundStyle(MemoMapTheme.Textsecondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var formContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                header

                titleSection

                descriptionSection

                photosSection

                ocrSection

                categorySection

                dateSection

                locationSection

                if let error = viewModel.errorMessage {
                    errorBanner(error)
                }

                updateButton
            }
            .padding(.horizontal, 15)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .background {
            MemoMapTheme.background
                .ignoresSafeArea()
        }
    }
    
    private var header: some View {
        HStack(alignment: .top, spacing: 12) {

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(MemoMapTheme.green.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .background(MemoMapTheme.White.opacity(0.6))
                    .clipShape(Circle())
                    .padding(.top,5)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Go back")

            VStack(alignment: .leading, spacing: 6) {
                Text("Update Memory")
                    .font(MemoFont.dmSansRegular(34))
                    .foregroundStyle(MemoMapTheme.black)

                Text("Make changes to your saved memory.")
                    .font(MemoFont.dmSansRegular(15))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }


    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Title", required: true)

            TextField(
                "Memory title",
                text: Binding(
                    get: { viewModel.title },
                    set: { viewModel.updateTitle($0) }
                )
            )
            .font(MemoFont.dmSansRegular(15))
            .foregroundStyle(MemoMapTheme.black)
            .focused($focusedField, equals: .title)
            .submitLabel(.done)
            .padding(14)
            .background(MemoMapTheme.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        viewModel.titleError == nil
                            ? MemoMapTheme.inputBorder
                            : Color.red.opacity(0.7),
                        lineWidth: 0.7
                    )
            }

            if let error = viewModel.titleError {
                fieldError(error)
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Description", required: false)

            ZStack(alignment: .topLeading) {
                if viewModel.description.isEmpty {
                    Text("Write your memory description...")
                        .font(MemoFont.dmSansRegular(15))
                        .foregroundStyle(
                            MemoMapTheme.Textsecondary.opacity(0.7)
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }

                TextEditor(
                    text: Binding(
                        get: { viewModel.description },
                        set: { viewModel.updateDescription($0) }
                    )
                )
                .font(MemoFont.dmSansRegular(15))
                .foregroundStyle(MemoMapTheme.black)
                .focused($focusedField, equals: .description)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(8)
            }
            .background(MemoMapTheme.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        MemoMapTheme.inputBorder,
                        lineWidth: 0.7
                    )
            }

            Button {
                toggleSpeechRecognition()
            } label: {
                HStack(spacing: 10) {
                    Image(
                        systemName: speech.isRecording
                            ? "stop.circle.fill"
                            : "mic.fill"
                    )

                    Text(
                        speech.isRecording
                            ? "Stop dictation"
                            : "Dictate description"
                    )

                    Spacer()

                    if speech.isRecording {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                    }
                }
                .font(MemoFont.dmSansRegular(15))
                .foregroundStyle(MemoMapTheme.green)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if speech.isRecording {
                Text("Listening… your words appear as you speak.")
                    .font(MemoFont.dmSansRegular(12))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
            }

            if let error = speech.errorMessage {
                Text(error)
                    .font(MemoFont.dmSansRegular(12))
                    .foregroundStyle(.red)
            }
        }
    }

    private func toggleSpeechRecognition() {
        if speech.isRecording {
            speech.stopRecording()
            focusedField = nil
            dismissKeyboard()
        } else {
            speech.errorMessage = nil
            speechBaseDescription = viewModel.description
            speech.recognizedText = ""

            focusedField = nil
            dismissKeyboard()

            speech.startRecording()
        }
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            sectionTitle("Photos", required: true)

            PhotosPicker(
                selection: $viewModel.selectedPhotoItems,
                maxSelectionCount: max(
                    1,
                    10 - viewModel.photos.count
                ),
                matching: .images
            ) {
                Label(
                    "Add More Photos",
                    systemImage: "photo.on.rectangle.angled"
                )
                .font(MemoFont.dmSansSemiBold(15))
                .foregroundStyle(MemoMapTheme.Textsecondary)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(MemoMapTheme.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            viewModel.photosError == nil
                                ? MemoMapTheme.inputBorder
                                : Color.red.opacity(0.7),
                            lineWidth: 0.7
                        )
                }
            }
            .disabled(
                viewModel.isLoadingPhotos
                    || viewModel.photos.count >= 10
            )

            if let error = viewModel.photosError {
                fieldError(error)
            }

            if !viewModel.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {

                        ForEach(
                            viewModel.photos.indices,
                            id: \.self
                        ) { index in

                            VStack(alignment: .leading, spacing: 6) {

                                Image(uiImage: viewModel.photos[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 140)
                                    .clipped()
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                                    .overlay(alignment: .topLeading) {
                                        if index == 0 {
                                            Text("COVER")
                                                .font(.caption2.bold())
                                                .foregroundStyle(.primary)
                                                .padding(6)
                                                .background(.white)
                                                .clipShape(
                                                    RoundedRectangle(
                                                        cornerRadius: 6
                                                    )
                                                )
                                                .padding(6)
                                        }
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            viewModel.removePhoto(at: index)
                                        } label: {
                                            Image(
                                                systemName: "xmark.circle.fill"
                                            )
                                            .font(.title3)
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(
                                                .white,
                                                .black.opacity(0.65)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .padding(6)
                                        .accessibilityLabel(
                                            "Remove photo \(index + 1)"
                                        )
                                    }

                                Text("Photo \(index + 1)")
                                    .font(MemoFont.dmSansRegular(12))
                                    .foregroundStyle(
                                        MemoMapTheme.Textsecondary
                                    )
                            }
                        }
                    }
                }
            }

            if viewModel.isLoadingPhotos {
                HStack(spacing: 8) {
                    ProgressView()

                    Text("Loading selected photos...")
                        .font(MemoFont.dmSansRegular(12))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                }
            }

            if viewModel.isReadingOCR {
                HStack(spacing: 8) {
                    ProgressView()

                    Text("Reading text from photos...")
                        .font(MemoFont.dmSansRegular(12))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                }
            }

            Text("You can keep, remove, or add photos. Maximum 10 photos.")
                .font(MemoFont.dmSansRegular(12))
                .foregroundStyle(MemoMapTheme.Textsecondary)
        }
    }

    private var ocrSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Recognized Text", required: false)

            if viewModel.ocrTags.isEmpty {
                Text("No recognized text available.")
                    .font(MemoFont.dmSansRegular(13))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(
                            Array(viewModel.ocrTags.enumerated()),
                            id: \.offset
                        ) { _, word in

                            Text(word)
                                .font(MemoFont.dmSansRegular(13))
                                .foregroundStyle(MemoMapTheme.White)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(MemoMapTheme.Textsecondary)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {

            sectionTitle("Category", required: true)

            Menu {
                ForEach(viewModel.categories, id: \.self) { item in
                    Button {
                        viewModel.selectCategory(item)
                    } label: {
                        if viewModel.category == item {
                            Label(item, systemImage: "checkmark")
                        } else {
                            Text(item)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(
                        viewModel.category.isEmpty
                            ? "Select a category"
                            : viewModel.category
                    )
                    .font(MemoFont.dmSansRegular(15))
                    .foregroundStyle(MemoMapTheme.black)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                }
                .padding(14)
                .background(MemoMapTheme.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            viewModel.categoryError == nil
                                ? MemoMapTheme.inputBorder
                                : Color.red.opacity(0.7),
                            lineWidth: 0.7
                        )
                }
            }
            .buttonStyle(.plain)

            if let error = viewModel.categoryError {
                fieldError(error)
            }
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            sectionTitle("Memory Date", required: true)

            DatePicker(
                "Date",
                selection: $viewModel.memoryDate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .font(MemoFont.dmSansRegular(15))
            .padding(12)
            .background(MemoMapTheme.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        MemoMapTheme.inputBorder,
                        lineWidth: 0.7
                    )
            }
            .tint(MemoMapTheme.green)
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            sectionTitle("Location", required: true)

            Button {
                focusedField = nil
                dismissKeyboard()
                showLocationPickerUpdate = true
            } label: {
                HStack(spacing: 12) {

                    Image(systemName: "map")
                        .font(.title3)
                        .foregroundStyle(MemoMapTheme.Textsecondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            viewModel.placeName ?? "Select a location"
                        )
                        .font(MemoFont.dmSansRegular(15))
                        .foregroundStyle(MemoMapTheme.black)

                        Text(
                            viewModel.placeName == nil
                                ? "Choose a place on the map."
                                : "Location attached to this memory."
                        )
                        .font(MemoFont.dmSansRegular(12))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(MemoMapTheme.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            viewModel.locationError == nil
                                ? MemoMapTheme.inputBorder
                                : Color.red.opacity(0.7),
                            lineWidth: 0.7
                        )
                }
            }
            .buttonStyle(.plain)

            if let error = viewModel.locationError {
                fieldError(error)
            }
        }
    }

    private var updateButton: some View {
        Button {
            speech.stopRecording()
            focusedField = nil
            dismissKeyboard()

            Task {
                await viewModel.updateMemory()
            }
        } label: {
            HStack(spacing: 10) {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(MemoMapTheme.White)
                }

                Text(
                    viewModel.isSaving
                        ? "Updating Memory..."
                        : "Update Memory"
                )
                .font(MemoFont.dmSansSemiBold(16))
            }
            .foregroundStyle(MemoMapTheme.White)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(MemoMapTheme.green)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(
            viewModel.isSaving
                || viewModel.isLoadingPhotos
                || viewModel.isReadingOCR
                || !viewModel.hasLoadedMemory
        )
    }

    private func sectionTitle(
        _ text: String,
        required: Bool
    ) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .font(MemoFont.dmSansBold(15))
                .foregroundStyle(MemoMapTheme.black)

            if required {
                Text("*")
                    .foregroundStyle(.red)
            }
        }
    }

    private func fieldError(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 13))

            Text(message)
                .font(MemoFont.dmSansRegular(12))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(MemoFont.dmSansRegular(13))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
