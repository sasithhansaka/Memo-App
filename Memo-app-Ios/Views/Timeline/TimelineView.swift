//
//  TimelineView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-02.
//
//


import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()

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


                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            header

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
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                        .frame(maxWidth: 520)
                        .frame(maxWidth: .infinity)
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
        
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Timeline")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(MemoMapTheme.black)

                Text("A chronological view of your life.")
                    .font(.system(size: 15))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 2)

            Image("LOGO")
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func yearSection(
        year: Int,
        memories: [Memory]
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(year))
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(MemoMapTheme.black)

            ForEach(Array(memories.enumerated()), id: \.element.id) {
                index, memory in

                memoryRow(memory)

                if index < memories.count - 1 {
                    Rectangle()
                        .fill(MemoMapTheme.inputBorder)
                        .frame(height: 1)
                        .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }


    private func memoryRow(_ memory: Memory) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Group {
                if let image = MemoryImageEncoder.decode(
                    memory.coverPhotoBase64
                ) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        MemoMapTheme.background

                        Image(systemName: "photo")
                            .font(.system(size: 27))
                            .foregroundStyle(
                                MemoMapTheme.Textsecondary
                            )
                    }
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 10) {
                Text(memory.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(MemoMapTheme.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(alignment: .top, spacing: 5) {
                    Text(
                        memory.memoryDate,
                        format: .dateTime.month(.abbreviated).day()
                    )

                    Text("•")

                    Text(
                        memory.placeName?.isEmpty == false
                            ? memory.placeName!
                            : "Location not added"
                    )
                    .lineLimit(2)
                }
                .font(.system(size: 14))
                .foregroundStyle(MemoMapTheme.Textsecondary)

                if let ocr = memory.ocrtext {
                    let tags = makeTags(from: ocr)

                    if !tags.isEmpty {
                        Text(
                            tags.map { "#\($0)" }
                                .joined(separator: " ")
                        )
                        .font(.system(size: 12))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                        .lineLimit(2)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        }
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func makeTags(from text: String) -> [String] {
        var seen = Set<String>()

        return text
            .components(separatedBy: .whitespacesAndNewlines)
            .map {
                $0.trimmingCharacters(
                    in: CharacterSet.alphanumerics.inverted
                )
            }
            .filter { $0.count >= 3 }
            .filter {
                seen.insert($0.lowercased()).inserted
            }
            .prefix(4)
            .map { $0 }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()

            Text("Loading your memories...")
                .font(.system(size: 14))
                .foregroundStyle(MemoMapTheme.Textsecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 36))
                .foregroundStyle(MemoMapTheme.Textsecondary)

            Text("Your timeline starts here")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(MemoMapTheme.black)

            Text("Memories you save will appear here, grouped by year.")
                .font(.system(size: 13))
                .foregroundStyle(MemoMapTheme.Textsecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 32))
                .foregroundStyle(MemoMapTheme.Textsecondary)

            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(MemoMapTheme.black)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                viewModel.stopListening()
                viewModel.startListening()
            }
            .foregroundStyle(MemoMapTheme.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

#Preview {
    TimelineView()
}
