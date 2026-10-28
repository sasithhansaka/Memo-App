//
//  AddMemoryView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-16.
//

import CoreLocation
import PhotosUI
import SwiftUI
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

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 16) {

                    header

                    titleSection
                        .padding(.top ,5)

                    descriptionSection
                        .padding(.top ,5)

                    photosSection
                        .padding(.top ,5)

                    ocrSection
                        .padding(.top ,5)

                    categorySection
                        .padding(.top ,5)

                    dateSection
                        .padding(.top ,5)

                    locationSection
                        .padding(.top ,5)

                    if let errorMessage = viewModel.errorMessage {

                        errorBanner(errorMessage)

                    }
                    saveButton
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }

            .scrollDismissesKeyboard(.interactively)
            .background {
                MemoMapTheme.background
                    .ignoresSafeArea()
            }
            .clipped()

            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(
                isPresented: $showLocationPicker
            ) {

                MemoryLocationPickerView {
                    name,
                    selectedLatitude,
                    selectedLongitude in

                    viewModel.selectLocation(

                        name: name,
                    latitude: selectedLatitude,
                        longitude: selectedLongitude
                    )

                }

            }

            .onChange(of: viewModel.selectedPhotoItems) {

                _,
                newItems in

                guard !newItems.isEmpty else {
                    return
                }

                Task {
                    await viewModel.loadSelectedPhotos(newItems)
                }

            }

            .onChange(of: speech.recognizedText) {
                _,
                newText in

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
    private var header: some View {

        HStack(spacing: 10) {

            VStack(alignment: .leading, spacing: 4) {
                Text("Create a memory")
                    .font(MemoFont.dmSansSemiBold(32))
                    .foregroundStyle(MemoMapTheme.black)
                Text("Capture the moments you want to keep.")
                    .font(MemoFont.dmSansRegular(14))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 2)

        }

        .frame(maxWidth: .infinity, alignment: .leading)

    }

    private var titleSection: some View {

        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Title", required: true)

            TextField(
                text: Binding(
                    get: { viewModel.title },
                    set: { viewModel.updateTitle($0) }
                ),
                prompt: Text("e.g. A day with my friends")
                    .foregroundColor(MemoMapTheme.Textsecondary.opacity(0.7))
            ) {
                Text("e.g. A day with my friends")
            }
            .font(MemoFont.dmSansRegular(15))
            .foregroundStyle(MemoMapTheme.black)
            .focused($focusedField, equals: .title)
            .submitLabel(.done)
            .padding(14)
            .background(MemoMapTheme.inputBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        viewModel.titleError == nil
                            ? MemoMapTheme.inputBorder
                            : Color.red.opacity(0.6),
                        lineWidth: 0.7
                    )
            }
            .accessibilityLabel("Memory title")
            .accessibilityHint("Enter a title up to 80 characters.")

            if let titleError = viewModel.titleError {
                fieldError(titleError)
            }

        }

    }

    private var descriptionSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Description", required: false)

            ZStack(alignment: .topLeading) {

                if viewModel.description.isEmpty {
                    Text("Write your memory description...")
                        .foregroundColor(MemoMapTheme.Textsecondary.opacity(0.7))
                        .font(MemoFont.dmSansRegular(15))
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
                .focused(
                    $focusedField,
                    equals: .description
                )

                .scrollContentBackground(.hidden)
                .frame(minHeight: 90)
                .padding(8)

            }
            .background(MemoMapTheme.inputBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
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
                    .font(.caption)
                    Text(
                        speech.isRecording
                            ? "Stop dictation"
                            : "Dictate description"

                    )
                    .font(MemoFont.dmSansRegular(15))
                    Spacer()
                    if speech.isRecording {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)

                    }

                }

                .foregroundStyle(MemoMapTheme.green.opacity(1))
                .padding(.vertical, 6)
                .contentShape(Rectangle())

            }

            .buttonStyle(.plain)
            if speech.isRecording {
                Text("Listening… your words appear as you speak.")
                    .font(MemoFont.dmSansRegular(12))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
            }

            if let speechError = speech.errorMessage {
                Text(speechError)
                    .font(MemoFont.dmSansRegular(12))
                    .foregroundStyle(.red)

            }
            
            Text("Typing and speech-to-text are both supported.")
                .font(MemoFont.dmSansRegular(12))
                .foregroundStyle(MemoMapTheme.Textsecondary)
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
                    "Choose Photos",
                    systemImage: "photo.on.rectangle.angled"

                )

                .font(MemoFont.dmSansSemiBold(15))

                .foregroundStyle(MemoMapTheme.Textsecondary)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(MemoMapTheme.inputBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )

                .overlay {

                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            viewModel.photosError == nil
                                ? Color.gray.opacity(0.2)
                                : Color.red.opacity(0.7),
                            lineWidth: 1

                        )

                }

            }

            .disabled(
                viewModel.isLoadingPhotos || viewModel.photos.count >= 10
            )

            if let photosError = viewModel.photosError {
                fieldError(photosError)
            }

            if !viewModel.photos.isEmpty {

                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {
                    HStack(
                        alignment: .top,
                        spacing: 12
                    ) {
                        ForEach(
                            viewModel.photos.indices,
                            id: \.self
                        ) { index in
                            
                            VStack(
                                alignment: .leading,
                                spacing: 6
                            ) {

                                Image(
                                    uiImage: viewModel.photos[index]
                                )

                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: 150,
                                    height: 140
                                )

                                .clipped()
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 12
                                    )
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
                                        viewModel.removePhoto(
                                            at: index
                                        )

                                    } label: {
                                        Image(systemName:"xmark.circle.fill"
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
                                    .font(.caption)
                                .foregroundStyle(.secondary)
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
                    Text("Extracting text from photos...")
                        .font(MemoFont.dmSansRegular(12))
                        .foregroundStyle(MemoMapTheme.Textsecondary)

                }

            }

            Text("Add at least one photo. You can select up to 10.")
                .font(MemoFont.dmSansRegular(12))
                .foregroundStyle(MemoMapTheme.Textsecondary)

        }

    }

    private var ocrSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            if viewModel.ocrTags.isEmpty {
       
            } else {
                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {

                    HStack(spacing: 8) {

                        ForEach(
                            Array(
                                viewModel.ocrTags.enumerated()
                            ),
                            id: \.offset
                        ) { _, word in
                            Text(word)
                                .font(.subheadline)
                                .foregroundStyle(MemoMapTheme.inputBackground)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    MemoMapTheme.Textsecondary
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
                ForEach(
                    viewModel.categories,
                    id: \.self
                ) { item in
                    Button {
                        viewModel.selectCategory(item)
                    } label: {
                        if viewModel.category == item {
                            Label(
                                item,
                                systemImage: "checkmark"
                            )
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
                    .foregroundStyle(
                        viewModel.category.isEmpty
                        ? MemoMapTheme.Textsecondary.opacity(0.7)
                            : MemoMapTheme.black
                    )

                    Spacer()

                    Image(systemName: "chevron.down")

                        .foregroundStyle(MemoMapTheme.Textsecondary)

                }

                .padding(14)
                .background(MemoMapTheme.inputBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
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
           .accessibilityLabel("Memory category")
            if let categoryError = viewModel.categoryError {

                fieldError(categoryError)
            }
        }
    }

    private var dateSection: some View {

        VStack(alignment: .leading, spacing: 8) {

            sectionTitle("Memory date", required: true)
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
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        MemoMapTheme.inputBorder,

                        lineWidth: 0.7
                    )
            }
            .foregroundStyle(MemoMapTheme.Textsecondary)
            .tint(MemoMapTheme.green)

        }
    }

    private var locationSection: some View {

        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Location", required: true)
            Button {
            focusedField = nil
                dismissKeyboard()
                showLocationPicker = true
            } label: {

                HStack(spacing: 12) {
                    Image(systemName: "map")
                        .font(.title3)
                        .foregroundStyle(MemoMapTheme.Textsecondary)

                    VStack(

                        alignment: .leading,
                        spacing: 4

                    ) {

                        Text(
                            viewModel.placeName ??
                                "Select a location"
                        )
                        .font(MemoFont.dmSansRegular(15))
                        .foregroundStyle(
                            viewModel.placeName == nil
                                ? MemoMapTheme.Textsecondary
                                : MemoMapTheme.black
                        )
                        
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
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )

                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            MemoMapTheme.inputBorder,
                            lineWidth: 0.7
                        )
                }
            }
            .buttonStyle(.plain)

            if let locationError = viewModel.locationError {
                Text(locationError)
                    .font(MemoFont.dmSansRegular(12))
                    .foregroundStyle(.red)
            }
        }

    }

    private func fieldError(
        _ message: String
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 6
        ) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 13))

            Text(message)
                .font(.caption)
                .fixedSize(
                 horizontal: false,
                    vertical: true
                )

        }

        .foregroundStyle(.red)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .accessibilityElement(children: .combine)

    }

    private func errorBanner(
        _ message: String
    ) -> some View {
        
        Text(message)

            .font(.subheadline)
            .foregroundStyle(.red)
            .frame(
                maxWidth: .infinity,
                alignment: .leading

            )
            .padding(12)
            .background(Color.red.opacity(0.08))
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
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
                .font(MemoFont.dmSansBold(15))
                .foregroundStyle(MemoMapTheme.black)
            if required {
                Text("*")
                    .foregroundStyle(.red)
            }
        }
    }

    private func dismissKeyboard() {

        UIApplication.shared.sendAction(
            #selector(
            UIResponder.resignFirstResponder
            ),
            to: nil,
            from: nil,
            for: nil

        )

    }

}
