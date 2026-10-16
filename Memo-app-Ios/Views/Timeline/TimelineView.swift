//
//  TimelineView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-02.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UIKit
import Combine

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()

    private let primaryColor = Color(
        red: 30 / 255,
        green: 35 / 255,
        blue: 33 / 255
    )

    private let secondaryColor = Color(
        red: 102 / 255,
        green: 107 / 255,
        blue: 99 / 255
    )

    private let cardDivider = Color(
        red: 220 / 255,
        green: 213 / 255,
        blue: 200 / 255
    )

  
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("timeline-bg")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                        .padding(.bottom, 24)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 30) {
                            if viewModel.isLoading {
                                loadingView
                            } else if let error = viewModel.errorMessage {
                                errorView(error)
                            } else if viewModel.memories.isEmpty {
                                emptyView
                            } else {
                                ForEach(
                                    viewModel.groupedYears,
                                    id: \.year
                                ) { section in
                                    yearSection(
                                        year: section.year,
                                        memories: section.memories
                                    )
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 120)
                        .padding(.horizontal, 24) // Left and right spacing

                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .top
                )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipped()
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }


    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Timeline")
                    .font(.system(size: 38, weight: .bold))
                    .tracking(-1.1)
                    .foregroundStyle(primaryColor)

                Spacer()

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

            Text("A chronological view of your life.")
                .font(.system(size: 16))
                .foregroundStyle(secondaryColor)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func yearSection(
        year: Int,
        memories: [TimelineMemory]
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(year))
                .font(.system(size: 30, weight: .bold))
                .tracking(-0.5)
                .foregroundStyle(primaryColor)

            ForEach(Array(memories.enumerated()), id: \.element.id) {
                index, memory in

                memoryRow(memory)

                if index < memories.count - 1 {
                    Rectangle()
                        .fill(cardDivider.opacity(0.9))
                        .frame(height: 1)
                        .padding(.top, 2)
                }
            }
        }
    }

    private func memoryRow(
        _ memory: TimelineMemory
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Group {
                if let image = MemoryImageEncoder.decode(
                    memory.coverPhotoBase64
                ) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color.white.opacity(0.65)

                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(secondaryColor.opacity(0.7))
                    }
                }
            }
            .frame(width: 100, height: 116)
            .clipShape(RoundedRectangle(cornerRadius: 22))

            VStack(alignment: .leading, spacing: 10) {
                Text(memory.title)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(primaryColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: 5) {
                    Text(memory.memoryDate, format: .dateTime.month(.abbreviated).day())
                    Text("•")

                    Text(
                        memory.placeName?.isEmpty == false
                            ? memory.placeName!
                            : "Location not added"
                    )
                    .lineLimit(2)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(secondaryColor)

                if !memory.tags.isEmpty {
                    Text(
                        memory.tags
                            .map { "#\($0)" }
                            .joined(separator: " ")
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(secondaryColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 5)
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading your memories...")
                .font(.system(size: 14))
                .foregroundStyle(secondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 36))
                .foregroundStyle(secondaryColor)

            Text("Your timeline starts here")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(primaryColor)

            Text("Memories you save will appear here, grouped by year.")
                .font(.system(size: 13))
                .foregroundStyle(secondaryColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.top, 50)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 32))
                .foregroundStyle(secondaryColor)

            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(primaryColor)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                viewModel.startListening()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}


@MainActor
final class TimelineViewModel: ObservableObject {
    @Published private(set) var memories: [TimelineMemory] = []
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    var groupedYears: [(year: Int, memories: [TimelineMemory])] {
        let grouped = Dictionary(grouping: memories) {
            Calendar.current.component(.year, from: $0.memoryDate)
        }

        return grouped.keys.sorted(by: >).map { year in
            let yearMemories = (grouped[year] ?? []).sorted {
                $0.memoryDate > $1.memoryDate
            }

            return (year: year, memories: yearMemories)
        }
    }

    func startListening() {
        guard listener == nil else { return }

        guard let userID = Auth.auth().currentUser?.uid else {
            isLoading = false
            errorMessage = "Please sign in to view your timeline."
            return
        }

        isLoading = true
        errorMessage = nil

        listener = db.collection("memories")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let error {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self.memories = []
                        self.isLoading = false
                        return
                    }

                    self.memories = documents.compactMap { document in
                        let data = document.data()

                        // Exclude soft-deleted memories.
                        if data["isDeleted"] as? Bool == true {
                            return nil
                        }

                        guard
                            let title = data["title"] as? String,
                            let cover = data["coverPhotoBase64"] as? String
                        else {
                            return nil
                        }

                        let date: Date
                        if let timestamp = data["memoryDate"] as? Timestamp {
                            date = timestamp.dateValue()
                        } else {
                            date = Date()
                        }

                        let placeName = data["placeName"] as? String
                        let ocrText = data["ocrText"] as? String ?? ""

                        return TimelineMemory(
                            id: document.documentID,
                            title: title,
                            memoryDate: date,
                            coverPhotoBase64: cover,
                            placeName: placeName,
                            ocrText: ocrText
                        )
                    }
                    .sorted { $0.memoryDate > $1.memoryDate }

                    self.isLoading = false
                    self.errorMessage = nil
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

struct TimelineMemory: Identifiable {
    let id: String
    let title: String
    let memoryDate: Date
    let coverPhotoBase64: String
    let placeName: String?
    let ocrText: String

    var tags: [String] {
        let words = ocrText
            .components(separatedBy: .whitespacesAndNewlines)
            .map {
                $0.trimmingCharacters(
                    in: CharacterSet.alphanumerics.inverted
                )
            }
            .filter { $0.count >= 3 }

        var seen = Set<String>()

        return words.filter {
            seen.insert($0.lowercased()).inserted
        }.prefix(4).map { $0 }
    }
}

#Preview {
    TimelineView()
}
