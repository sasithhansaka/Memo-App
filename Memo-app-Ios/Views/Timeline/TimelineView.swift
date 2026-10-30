//
//  TimelineView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-02.
//
//
import SwiftUI
struct TimelineView: View {
    
    @State private var selectedPhotoIndices: [String: Int] = [:]
    @StateObject private var viewModel = TimelineViewModel()
    @State private var selectedYear: Int? = nil
    @State private var expandedDescriptions: Set<String> = []
    private var availableYears: [Int] {
        viewModel.groupedYears.map(\.year)
    }
    private var visibleSections: [(year: Int, memories: [Memory])] {
        viewModel.groupedYears.filter { section in
            selectedYear == nil || section.year == selectedYear
        }
    }
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    yearFilters
                    if viewModel.isLoading {
                        loadingView
                    } else if let error = viewModel.errorMessage {
                        errorView(error)
                    } else if viewModel.memories.isEmpty {
                        emptyView
                    } else if visibleSections.isEmpty {
                        emptyFilterView
                    } else {
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(visibleSections, id: \.year) { section in
                                yearSection(
                                    year: section.year,
                                    memories: section.memories
                                )
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
//                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .background {
                MemoMapTheme.background
                    .ignoresSafeArea()
            }
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
                    .font(MemoFont.dmSansRegular(34))
                    .foregroundStyle(MemoMapTheme.black)
                Text("Your memories, organized by time.")
                    .font(MemoFont.dmSansRegular(15))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 2)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var yearFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                yearChip(title: "All", year: nil)
                ForEach(availableYears, id: \.self) { year in
                    yearChip(title: String(year), year: year)
                }
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 16)
        }
    }
    
    private func yearChip(
        title: String,
        year: Int?
    ) -> some View {
        let isSelected = selectedYear == year
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedYear = year
            }
        } label: {
            Text(title)
                .font(MemoFont.dmSansMedium(14))
                .foregroundStyle(
                    isSelected ? MemoMapTheme.White : MemoMapTheme.green
                )
                .frame(minWidth: 76)
                .frame(height: 42)
                .background {
                    Capsule()
                        .fill(
                            isSelected
                                ? MemoMapTheme.green
                                : Color.white.opacity(0.45)
                        )
                }
                .overlay {
                    Capsule()
                        .stroke(
                            isSelected
                                ? Color.clear
                                : MemoMapTheme.inputBorder.opacity(0.8),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }
    
    private func yearSection(
        year: Int,
        memories: [Memory]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(year))
                    .font(MemoFont.dmSansBold(23))
                    .foregroundStyle(MemoMapTheme.black)
                Text("\(memories.count) memories")
                    .font(MemoFont.dmSansRegular(13))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                ForEach(memories) { memory in
                    NavigationLink {
                        MemoryDetailView(memory: memory)
                    } label: {
                        memoryFeedCard(memory)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func memoryFeedCard(_ memory: Memory) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            memoryHeader(memory)
            memoryPhotoCarousel(memory)
            descriptionSection(memory)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }
    
    private func memoryHeader(_ memory: Memory) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Group {
                if let image = MemoryImageEncoder.decode(
                    memory.coverPhotoBase64
                ) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle()
                        .fill(MemoMapTheme.lightGreen)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(MemoMapTheme.green)
                        }
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 5) {
                Text(memory.title)
                    .font(MemoFont.dmSansBold(16))
                    .foregroundStyle(MemoMapTheme.black)
                    .lineLimit(1)
                HStack(spacing: 5) {
                    Text(
                        memory.memoryDate,
                        format: .dateTime
                            .month(.abbreviated)
                            .day()
                            .year()
                    )
                    Text("·")
                    Image(systemName: "map.fill")
                        .font(.system(size: 11))
                    Text(
                        memory.placeName?.isEmpty == false
                            ? memory.placeName!
                            : "Location not added"
                    )
                    .lineLimit(1)
                }
                .font(MemoFont.dmSansRegular(13))
                .foregroundStyle(MemoMapTheme.Textsecondary.opacity(0.9))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
    }
    
    private func memoryPhotoCarousel(_ memory: Memory) -> some View {

        let memoryID = String(describing: memory.id)

        let photoData = memory.photoBase64.flatMap { photos in
            photos.isEmpty ? nil : photos
        } ?? [memory.coverPhotoBase64]

        let images = photoData.enumerated().compactMap { index, base64 in
            MemoryImageEncoder.decode(base64).map { (index, $0) }
        }

        let currentIndex = selectedPhotoIndices[memoryID] ?? 0

        return GeometryReader { geometry in

            ZStack(alignment: .bottom) {

                if images.isEmpty {

                    ZStack {
                        MemoMapTheme.lightGreen

                        Image(systemName: "photo")
                            .font(.system(size: 36))
                            .foregroundStyle(MemoMapTheme.green)
                    }
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )

                } else {

                    TabView(
                        selection: Binding(
                            get: {
                                currentIndex
                            },
                            set: { newIndex in
                                selectedPhotoIndices[memoryID] = newIndex
                            }
                        )
                    ) {

                        ForEach(images, id: \.0) { item in

                            Image(uiImage: item.1)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )
                                .clipped()
                                .tag(item.0)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    if images.count > 1 {

                        HStack(spacing: 7) {

                            ForEach(images, id: \.0) { item in

                                Circle()
                                    .fill(
                                        currentIndex == item.0
                                        ? MemoMapTheme.green
                                        : MemoMapTheme.green.opacity(0.5)
                                    )
                                    .frame(width: 7, height: 7)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipped()
        }
        .frame(height: 325)
        .frame(maxWidth: .infinity)
        .clipped()
    }
    
    
    private func descriptionSection(_ memory: Memory) -> some View {
        let key = String(describing: memory.id)
        let isExpanded = expandedDescriptions.contains(key)
        let description = memory.description ?? ""
        let characterLimit = 40
        return (
            Text(memory.title + " ")
                .font(MemoFont.dmSansBold(15))
                .foregroundColor(MemoMapTheme.black)
            +
            
            Text(
                isExpanded || description.count <= characterLimit
                    ? description
                    : String(description.prefix(characterLimit)) + "... "
            )
            .font(MemoFont.dmSansRegular(15))
            .foregroundColor(MemoMapTheme.Textsecondary.opacity(0.9))
            +
            (
                description.count > characterLimit && !isExpanded
                    ? Text("more")
                        .font(MemoFont.dmSansMedium(13))
                        .foregroundColor(MemoMapTheme.Textsecondary.opacity(0.7))
                    : Text("")
            )
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            guard description.count > characterLimit, !isExpanded else {
                return
            }
            var transaction = Transaction()
            transaction.animation = nil
            withTransaction(transaction) {
                expandedDescriptions.insert(key)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading your memories...")
                .font(MemoFont.dmSansRegular(14))
                .foregroundStyle(MemoMapTheme.Textsecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 36))
                .foregroundStyle(MemoMapTheme.green)
            Text("Your timeline starts here")
                .font(MemoFont.dmSansBold(19))
                .foregroundStyle(MemoMapTheme.black)
            Text("Memories you save will appear here, grouped by year.")
                .font(MemoFont.dmSansRegular(14))
                .foregroundStyle(MemoMapTheme.Textsecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    private var emptyFilterView: some View {
        Text("No memories found for this year.")
            .font(MemoFont.dmSansRegular(14))
            .foregroundStyle(MemoMapTheme.Textsecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 35)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 32))
                .foregroundStyle(MemoMapTheme.Textsecondary)
            Text(message)
                .font(MemoFont.dmSansRegular(14))
                .foregroundStyle(MemoMapTheme.black)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                viewModel.stopListening()
                viewModel.startListening()
            }
            .foregroundStyle(MemoMapTheme.green)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}
#Preview {
    TimelineView()
}
