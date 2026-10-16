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


    private enum InputField: Hashable {
        case title
        case description
        case ocr
    }

    @FocusState private var focusedField: InputField?

    @State private var title = ""
    @State private var description = ""
    @State private var category = ""
    @State private var memoryDate = Date()

    @State private var photos: [UIImage] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    @State private var ocrText = ""
    @State private var photoOCRTexts: [String] = []

    @State private var speechBaseDescription = ""

    @State private var latitude = 0.0
    @State private var longitude = 0.0
    @State private var placeName: String?

    @State private var showLocationPicker = false
    @State private var isSaving = false
    @State private var isLoadingPhotos = false
    @State private var isReadingOCR = false

    @State private var errorMessage: String?
    @State private var showSuccessAlert = false

    @StateObject private var speech = SpeechRecognitionService()

    private let memoryService = MemoryService()

    private let categories = [
        "Travels",
        "Family",
        "University & Education",
        "Friends",
        "Other"
    ]

    private let cream = Color(
        red: 0.98,
        green: 0.97,
        blue: 0.93
    )

    private let green = Color(
        red: 0.20,
        green: 0.42,
        blue: 0.29
    )

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

                    if let errorMessage {
                        errorBanner(errorMessage)
                    }

                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(cream.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .background {
                OutsideTapKeyboardDismiss {
                    focusedField = nil
                    dismissKeyboard()
                }
                .frame(width: 0, height: 0)
            }
            .navigationDestination(
                isPresented: $showLocationPicker
            ) {
                MemoryLocationPickerView {
                    name, selectedLatitude, selectedLongitude in

                    placeName = name
                    latitude = selectedLatitude
                    longitude = selectedLongitude
                    errorMessage = nil
                }
            }
            .onChange(of: selectedPhotoItems) { _, newItems in
                guard !newItems.isEmpty else { return }

                Task {
                    await loadSelectedPhotos(newItems)
                }
            }
            .onChange(of: speech.recognizedText) { _, newText in
                updateLiveDescription(with: newText)
            }
            .alert(
                "Memory Saved",
                isPresented: $showSuccessAlert
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
        VStack(alignment: .leading, spacing: 26) {
            Button {
                speech.stopRecording()
                dismissKeyboard()
                dismiss()
            } label: {
                    EmptyView()
            }
            
            
//            } label: {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundStyle(Color.primary)
//                    .frame(width: 32, height: 32)
//                    .contentShape(Rectangle())
//            }

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("New memory")
                        .font(.system(size: 34, weight: .bold))
                        .tracking(-0.8)
                        .foregroundStyle(Color.primary)

                    Text("Save the details while they are fresh.")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                ZStack {
                    Image("LOGO")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: 100,
                            height: 100
                        )
                }
                .frame(width: 76, height: 76)
            }
        }
        .padding(.bottom, 12)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Title", required: true)

            TextField(
                "e.g. A day with my friends",
                text: titleBinding
            )
            .focused($focusedField, equals: .title)
            .submitLabel(.done)
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("\(title.count)/80 characters")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var titleBinding: Binding<String> {
        Binding(
            get: { title },
            set: { title = String($0.prefix(80)) }
        )
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Description", required: false)

            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("Write your memory description...")
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }

                TextEditor(text: $description)
                    .focused($focusedField, equals: .description)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
                    .padding(8)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))

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

                    if speech.isRecording {
                        Spacer()

                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                    }
                }
                .foregroundStyle(green)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }

            if speech.isRecording {
                Text("Listening… your words appear as you speak.")
                    .font(.caption)
                    .foregroundStyle(green)
            }

            if let speechError = speech.errorMessage {
                Text(speechError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Text("Typing and speech-to-text are optional.")
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

            speechBaseDescription = description

            speech.recognizedText = ""

            focusedField = nil
            dismissKeyboard()
            speech.startRecording()
        }
    }

    private func updateLiveDescription(with newText: String) {
        guard speech.isRecording || !newText.isEmpty else {
            return
        }

        let base = speechBaseDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let spoken = newText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if spoken.isEmpty {
            description = speechBaseDescription
        } else if base.isEmpty {
            description = spoken
        } else {
            description = base + " " + spoken
        }
    }

    
     private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Photos", required: true)

            Text(
                "Add at least one photo. Your first photo becomes the cover."
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            PhotosPicker(
                selection: $selectedPhotoItems,
                maxSelectionCount: max(1, 10 - photos.count),
                matching: .images
            ) {
                Label(
                    "Choose Photos",
                    systemImage: "photo.on.rectangle.angled"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(green)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isLoadingPhotos || photos.count >= 10)

            if !photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(photos.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 6) {
                                Image(uiImage: photos[index])
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
                                                .foregroundStyle(.white)
                                                .padding(6)
                                                .background(green)
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
                                            removePhoto(at: index)
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
                                        .padding(6)
                                    }

                                Text("Photo \(index + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            if isLoadingPhotos {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading selected photos…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if isReadingOCR {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Extracting text from photos…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @MainActor
    private func loadSelectedPhotos(
        _ items: [PhotosPickerItem]
    ) async {
        guard !items.isEmpty, !isLoadingPhotos else { return }

        isLoadingPhotos = true
        errorMessage = nil

        let startingIndex = photos.count

        for item in items {
            guard photos.count < 10 else { break }

            guard
                let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                continue
            }

            photos.append(image)
            photoOCRTexts.append("")
        }

        selectedPhotoItems = []
        isLoadingPhotos = false

        guard photos.count > startingIndex else {
            errorMessage = "Could not load the selected photos. Please try again."
            return
        }

        isReadingOCR = true
        defer { isReadingOCR = false }

        for index in startingIndex..<photos.count {
            let extractedText = await MemoryOCRService.recognizeText(
                in: photos[index]
            )

            photoOCRTexts[index] = extractedText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        }

        rebuildOCRText()
    }

    private func removePhoto(at index: Int) {
        guard photos.indices.contains(index) else { return }

        photos.remove(at: index)

        if photoOCRTexts.indices.contains(index) {
            photoOCRTexts.remove(at: index)
        }

        rebuildOCRText()
    }

    private func rebuildOCRText() {
        ocrText = photoOCRTexts
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }

    private var ocrTags: [String] {
        ocrText
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
    }

    private var ocrSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            if ocrTags.isEmpty {
                Text("")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(
                            Array(ocrTags.enumerated()),
                            id: \.offset
                        ) { _, word in
                            Text(word)
                                .font(.subheadline)
                                .foregroundStyle(green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(green.opacity(0.10))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

//            TextEditor(text: $ocrText)
//                .focused($focusedField, equals: .ocr)
//                .scrollContentBackground(.hidden)
//                .frame(minHeight: 80)
//                .padding(8)
//                .background(.white)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//
//            Text("OCR is optional. You can edit the extracted text.")
//                .font(.caption)
//                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Category", required: true)

            Menu {
                ForEach(categories, id: \.self) { item in
                    Button {
                        category = item
                        errorMessage = nil
                    } label: {
                        if category == item {
                            Label(item, systemImage: "checkmark")
                        } else {
                            Text(item)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(
                        category.isEmpty
                            ? "Select a category"
                            : category
                    )
                    .foregroundStyle(
                        category.isEmpty ? .secondary : .primary
                    )

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Date

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Memory date", required: true)

            DatePicker(
                "Date",
                selection: $memoryDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .padding(12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - User-Selected Location Only

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
                        .foregroundStyle(green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(placeName ?? "Select a location")
                            .foregroundStyle(.primary)

                        Text(
                            placeName == nil
                                ? "Choose a place on the map."
                                : "Selected location attached to this memory."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            focusedField = nil
            dismissKeyboard()

            Task {
                await saveMemory()
            }
        } label: {
            HStack(spacing: 10) {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                }

                Text(isSaving ? "Saving Memory..." : "Save Memory")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(green)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isSaving || isLoadingPhotos)
    }

    @MainActor
    private func saveMemory() async {
        errorMessage = nil

        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedTitle.isEmpty else {
            errorMessage = "Please enter a memory title."
            return
        }

        guard !category.isEmpty else {
            errorMessage = "Please select a category."
            return
        }

        guard !photos.isEmpty else {
            errorMessage = "Please add at least one photo."
            return
        }

        guard !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await memoryService.saveMemory(
                title: trimmedTitle,
                description: description,
                category: category,
                memoryDate: memoryDate,
                photos: photos,
                ocrText: ocrText,
                latitude: latitude,
                longitude: longitude,
                placeName: placeName
            )

            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Keyboard

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    // MARK: - Reusable Section Title

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
}

// MARK: - Outside Tap Keyboard Dismissal

private struct OutsideTapKeyboardDismiss: UIViewRepresentable {
    let onDismiss: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            guard
                let window = view.window,
                context.coordinator.attachedWindow !== window
            else {
                return
            }

            if let oldWindow = context.coordinator.attachedWindow,
               let oldRecognizer = context.coordinator.tapRecognizer {
                oldWindow.removeGestureRecognizer(oldRecognizer)
            }

            let recognizer = UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap)
            )

            recognizer.cancelsTouchesInView = false
            recognizer.delegate = context.coordinator

            window.addGestureRecognizer(recognizer)

            context.coordinator.attachedWindow = window
            context.coordinator.tapRecognizer = recognizer
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onDismiss = onDismiss
    }

    static func dismantleUIView(
        _ uiView: UIView,
        coordinator: Coordinator
    ) {
        if let window = coordinator.attachedWindow,
           let recognizer = coordinator.tapRecognizer {
            window.removeGestureRecognizer(recognizer)
        }

        coordinator.attachedWindow = nil
        coordinator.tapRecognizer = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onDismiss: () -> Void
        weak var attachedWindow: UIWindow?
        var tapRecognizer: UITapGestureRecognizer?

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        @objc func handleTap() {
            onDismiss()
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {
            var currentView = touch.view

            while let view = currentView {
                if view is UIControl ||
                    view is UITextField ||
                    view is UITextView {
                    return false
                }

                currentView = view.superview
            }

            return true
        }
    }
}
