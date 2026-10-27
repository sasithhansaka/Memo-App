//
//  MemoAppWidget.swift
//  MemoAppWidget
//
//  Created by student3 on 2026-10-27.
//

import WidgetKit
import SwiftUI
import UIKit

struct MemoryWidgetEntry: TimelineEntry {
    let date: Date
    let memories: [MemoryWidgetItem]
    let selectedIndex: Int

    var selectedMemory: MemoryWidgetItem? {
        guard !memories.isEmpty else {
            return nil
        }

        return memories[
            selectedIndex % memories.count
        ]
    }
}

struct MemoryWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> MemoryWidgetEntry {
        MemoryWidgetEntry(
            date: .now,
            memories: [
                MemoryWidgetItem(
                    id: "sample",
                    title: "A Beautiful Memory",
                    memoryDate: .now,
                    placeName: "Your favourite place",
                    coverPhotoBase64: ""
                )
            ],
            selectedIndex: 0
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (MemoryWidgetEntry) -> Void
    ) {
        let memories = MemoryWidgetStorage.load()

        completion(
            MemoryWidgetEntry(
                date: .now,
                memories: memories,
                selectedIndex: 0
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<MemoryWidgetEntry>) -> Void
    ) {
        let memories = MemoryWidgetStorage.load()
        
        print("Widget loaded memories:", memories.count)
        print("WIDGET EXTENSION: Loaded memories:", memories.count)

        for memory in memories {
            print(
                "Widget memory:",
                memory.id,
                "Photo Base64 length:",
                memory.coverPhotoBase64.count
            )
        }


        guard !memories.isEmpty else {
            let entry = MemoryWidgetEntry(
                date: .now,
                memories: [],
                selectedIndex: 0
            )

            completion(
                Timeline(
                    entries: [entry],
                    policy: .after(
                        Calendar.current.date(
                            byAdding: .hour,
                            value: 1,
                            to: .now
                        )!
                    )
                )
            )

            return
        }

        let entries: [MemoryWidgetEntry] = memories.indices.map {
            index in

            let entryDate = Calendar.current.date(
                byAdding: .minute,
                value: index * 15,
                to: .now
            ) ?? .now

            return MemoryWidgetEntry(
                date: entryDate,
                memories: memories,
                selectedIndex: index
            )
        }

        completion(
            Timeline(
                entries: entries,
                policy: .after(
                    Calendar.current.date(
                        byAdding: .hour,
                        value: 1,
                        to: .now
                    )!
                )
            )
        )
    }
}

struct MemoAppWidgetEntryView: View {
    let entry: MemoryWidgetProvider.Entry

    var body: some View {
        Group {
            if let memory = entry.selectedMemory {
                memoryCard(memory)
            } else {
                emptyState
            }
        }
    }

    private func memoryCard(_ memory: MemoryWidgetItem) -> some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {

                memoryImage(memory)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height * 0.68
                    )
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Label {
                        Text(
                            memory.memoryDate,
                            format: .dateTime
                                .day()
                                .month(.abbreviated)
                                .year()
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(MemoFont.dmSansMedium(10))
                    .foregroundStyle(MemoMapTheme.Textsecondary)

                    Label {
                        Text(locationText(for: memory))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    } icon: {
                        Image(systemName: "map")
                    }
                    .font(MemoFont.dmSansRegular(10))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                }
                .padding(.horizontal, 8)
                .padding(.top, 5)

                Spacer(minLength: 0)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .topLeading
            )
            .background(MemoMapTheme.background)
            .clipShape(
                RoundedRectangle(cornerRadius: 2)
            )
        }
    }

    private func locationText(for memory: MemoryWidgetItem) -> String {
        guard let placeName = memory.placeName?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !placeName.isEmpty else {
            return "Location not added"
        }

        return placeName
    }

    @ViewBuilder
    private func memoryImage(_ memory: MemoryWidgetItem) -> some View {
        if let data = Data(base64Encoded: memory.coverPhotoBase64),
           let image = UIImage(data: data) {

            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color.gray.opacity(0.15)

                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "book.closed")
                .font(MemoFont.dmSansRegular(24))

            Text("Your memories await")
                .font(MemoFont.dmSansBold(16))

            Text("Save a memory in MemoMap to see it here.")
                .font(MemoFont.dmSansRegular(11))
                .multilineTextAlignment(.center)
                .foregroundStyle(MemoMapTheme.Textsecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct MemoAppWidget: Widget {
    let kind = "MemoAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: MemoryWidgetProvider()
        ) { entry in
            MemoAppWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MemoMap Memories")
        .description(
            "Rediscover your saved memories, photos, dates, and places."
        )
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    MemoAppWidget()
} timeline: {
    MemoryWidgetEntry(
        date: .now,
        memories: [
            MemoryWidgetItem(
                id: "preview-1",
                title: "Beach Day",
                memoryDate: .now,
                placeName: "Mirissa Beach",
                coverPhotoBase64: ""
            ),
            MemoryWidgetItem(
                id: "preview-2",
                title: "A Day with Friends",
                memoryDate: .now,
                placeName: "Colombo",
                coverPhotoBase64: ""
            )
        ],
        selectedIndex: 0
    )
}
