//
//  AddMemoryView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-16.
//


import SwiftUI
import PhotosUI
import CoreLocation
import UIKit

struct AddMemoryView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = AddMemoryViewModel()
    @StateObject private var speech = SpeechRecognitionService()
    @FocusState private var focusedField: InputField?
    @State private var showLocationPicker = false
    @State private var speechBaseDescription = ""

    private enum InputField: Hashable {
        case title
        case description
    }

    private let accentColor = Color(
        red: 0.15,
        green: 0.42,
        blue: 0.30
    )

    private let pageBackground = Color(
        red: 0.97,
        green: 0.96,
        blue: 0.92
    )

    private let inputBackground = Color.white

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    headerSection
                    titleSection
                    descriptionSection
                    photosSection
                    ocrSection
                    categorySection
                    dateSection
                    locationSection

                    if let errorMessage = viewModel.errorMessage {
                        errorBanner(errorMessage)
                    }

                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(pageBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(
                isPresented: $showLocationPicker
            ) {
                MemoryLocationPickerView {
                    name, selectedLatitude, selectedLongitude in

                    viewModel.selectLocation(
                        name: name,
                        latitude: selectedLatitude,
                        longitude: selectedLongitude
                    )
                }
            }
            
            .onChange(of: viewModel.selectedPhotoItems) { _, newItems in
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
                "Memory Saved",
                isPresented: $viewModel.showSuccessAlert
            ) {
                Button("Done") {
                    speech.stopRecording()
                    dismiss()
                }
            } message: {
                Text("Your memory was saved successfully.")
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 24) {

            Button {
                speech.stopRecording()
                dismissKeyboard()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("New memory")
                        .font(.system(size: 34, weight: .bold))
                        .tracking(-0.8)
                        .foregroundStyle(.primary)

                    Text("Save the details while they are fresh.")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Image("LOGO")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 76, height: 76)
            }
        }
        .padding(.bottom, 10)
    }


    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Title", required: true)

            TextField(
                "e.g. A day with my friends",
                text: Binding(
                    get: { viewModel.title },
                    set: { viewModel.updateTitle($0) }
                )
            )
            .focused($focusedField, equals: .title)
            .submitLabel(.done)
            .padding(14)
            .background(inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }

            HStack {
                Spacer()

                Text("\(viewModel.title.count)/80")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }


    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Description", required: false)

            ZStack(alignment: .topLeading) {
                if viewModel.description.isEmpty {
                    Text("Write your memory description...")
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }

                TextEditor(
                    text: Binding(
                        get: { viewModel.description },
                        set: { viewModel.updateDescription($0) }
                    )
                )
                .focused($focusedField, equals: .description)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 110)
                .padding(8)
            }
            .background(inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
                    .font(.title3)

                    Text(
                        speech.isRecording
                            ? "Stop dictation"
                            : "Dictate description"
                    )
                    .font(.headline)

                    Spacer()

                    if speech.isRecording {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                    }
                }
                .foregroundStyle(accentColor)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if speech.isRecording {
                Text("Listening… your words appear as you speak.")
                    .font(.caption)
                    .foregroundStyle(accentColor)
            }

            if let speechError = speech.errorMessage {
                Text(speechError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Text("Typing and speech-to-text are both supported.")
                .font(.caption)
                .foregroundStyle(.secondary)
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

            Text("Add photos to your memory")
                .font(.caption)
                .foregroundStyle(.secondary)

            PhotosPicker(
                selection: $viewModel.selectedPhotoItems,
                maxSelectionCount: max(
                    1,
                    10 - viewModel.photos.count
                ),
                matching: .images
            ) {
                Label(
                    "Choose Photos",
                    systemImage: "photo.on.rectangle.angled"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(accentColor)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(
                viewModel.isLoadingPhotos ||
                viewModel.photos.count >= 10
            )

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
                                    }
                            }
                        }
                    }
                }
            }

            if viewModel.isLoadingPhotos {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading selected photos...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.isReadingOCR {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Extracting text from photos...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Add at least one photo. You can select up to 10.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }


    private var ocrSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Detected text", required: false)

            if viewModel.ocrTags.isEmpty {
                Text("Text detected in your photos will appear here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(
                            Array(viewModel.ocrTags.enumerated()),
                            id: \.offset
                        ) { _, word in
                            Text(word)
                                .font(.subheadline)
                                .foregroundStyle(accentColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    accentColor.opacity(0.10)
                                )
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
                    .foregroundStyle(
                        viewModel.category.isEmpty
                            ? Color.secondary
                            : Color.primary
                    )

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }


    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Memory date", required: true)

            DatePicker(
                "Date",
                selection: $viewModel.memoryDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .padding(12)
            .background(inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Location", required: false)

            Button {
                focusedField = nil
                dismissKeyboard()
                showLocationPicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title3)
                        .foregroundStyle(accentColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            viewModel.placeName ??
                            "Select a location"
                        )
                        .foregroundStyle(.primary)

                        Text(
                            viewModel.placeName == nil
                                ? "Choose a place on the map."
                                : "Location attached to this memory."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var saveButton: some View {
        Button {
            speech.stopRecording()
            focusedField = nil
            dismissKeyboard()

            Task {
                await viewModel.saveMemory()
            }
        } label: {
            HStack(spacing: 10) {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                }

                Text(
                    viewModel.isSaving
                        ? "Saving Memory..."
                        : "Save Memory"
                )
                .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(
            viewModel.isSaving ||
            viewModel.isLoadingPhotos
        )
    }

    private func sectionTitle(
        _ text: String,
        required: Bool
    ) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.headline)

            if required {
                Text("*")
                    .foregroundStyle(.red)
            }
        }
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
