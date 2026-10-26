//
//  HomeView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//

import Combine
import Foundation
import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedMemory: Memory?

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
//        GridItem(.flexible()),
    ]

    @StateObject private var viewModel = HomeViewModel()

    //    @State private var selectedMemory: Memory?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {

                        header
                        searchBanner
                        nearbyMemoryCard
                        collectionBanner
                        recentlyAddedSection

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
                Text(greeting)
                    .font(MemoFont.dmSansRegular(34))
                    .foregroundStyle(MemoMapTheme.black)

                Text("Your memories are waiting to be rediscovered.")
                    .font(MemoFont.dmSansRegular(15))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 2)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let time = Calendar.current.component(.hour, from: Date())

        switch time {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
    
    private var nearbyMemoryCard: some View {
        NavigationLink {
            AddMemoryView()
        } label: {
            VStack(alignment: .leading, spacing: 0) {

                Image("create-memory")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 185)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5))

                VStack(alignment: .leading, spacing: 12) {

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Every moment deserves a memory.")
                            .font(MemoFont.dmSansBold(18))
                            .foregroundStyle(MemoMapTheme.black)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top , 12)

                        Text("Capture your favorite moments, save special places, and keep your stories close forever.")
                            .font(MemoFont.dmSansRegular(15))
                            .foregroundStyle(
                                MemoMapTheme.Textsecondary.opacity(0.9)
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Spacer()

                        HStack(spacing: 7) {
                            Text("Create memory")
                                .font(MemoFont.dmSansSemiBold(15))

                            Image(systemName: "book.closed.fill")
                        }
                        .foregroundStyle(MemoMapTheme.White)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(MemoMapTheme.green)
                        .clipShape(Capsule())
                    }
                }
                
                .background(MemoMapTheme.background)
            }
        }
        
        .buttonStyle(.plain)
    }
    

    
    private var searchBanner: some View {
        NavigationStack {
            NavigationLink {
                SearchView()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(MemoMapTheme.lightGreen))
                            .frame(width: 40, height: 40)

                        Image("Search Icon")
                            .resizable()
                            .frame(width: 17, height: 17)

                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Find all memories")
                            .font(MemoFont.dmSansMedium(18))
//                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(MemoMapTheme.black)

                        Text("Search by place, category or story")
                            .font(MemoFont.dmSansRegular(15))
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 0)
                    
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MemoMapTheme.White)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MemoMapTheme.inputBorder, lineWidth: 0.3)
                }
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var collectionBanner: some View {
            VStack(alignment: .leading, spacing: 18) {
                Text("Memory collection")
                    .font(MemoFont.dmSansRegular(20))
                    .foregroundStyle(MemoMapTheme.black)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    collectionCard(
                        title: "Memories",
                        count: viewModel.totalMemories,
                        image: "memories",
                        decoration: .memories
                    )
                    collectionCard(
                        title: "This year",
                        count: viewModel.thisYearTotal,
                        image: "Tyear",
                        decoration: .leaves
                    )
                    collectionCard(
                        title: "Places",
                        count: viewModel.recentMemoryCount,
                        image: "places",
                        decoration: .location
                    )
                    collectionCard(
                        title: "Photos",
                        count: viewModel.photosCount,
                        image: "memories",
                        decoration: .photos
                    )
                }
            }
        }
        private func collectionCard(
            title: String,
            count: Int,
            image: String,
            decoration: CollectionDecoration
        ) -> some View {
            HStack(spacing: 16) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .padding(5)
                    .background(
                        MemoMapTheme.lightGreen.opacity(0.32)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(MemoFont.dmSansRegular(18))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text("\(count)")
                        .font(MemoFont.dmSansBold(22))
                        .foregroundStyle(MemoMapTheme.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            .background {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .fill(MemoMapTheme.inputBackground.opacity(0.35))
                    CollectionWave()
                        .fill(
                            MemoMapTheme.lightGreen.opacity(0.18)
                        )
                        .frame(width: 130, height: 65)
                        .offset(x: 8, y: 8)
                    Image(systemName: decoration.symbol)
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(
                            MemoMapTheme.green.opacity(0.16)
                        )
                        .rotationEffect(.degrees(-12))
                        .offset(x: -12, y: -5)
                }
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .stroke(
                    MemoMapTheme.inputBorder.opacity(0.3),
                    lineWidth: 1
                )
            }
        }
        private enum CollectionDecoration {
            case memories
            case leaves
            case location
            case photos
            var symbol: String {
                switch self {
                case .memories:
                    return "heart"
                case .leaves:
                    return "leaf"
                case .location:
                    return "mappin.and.ellipse"
                case .photos:
                    return "mountain.2"
                }
            }
        }
        private struct CollectionWave: Shape {
            func path(in rect: CGRect) -> Path {
                Path { path in
                    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                    path.addCurve(
                        to: CGPoint(x: rect.maxX, y: rect.minY + 15),
                        control1: CGPoint(
                            x: rect.width * 0.35,
                            y: rect.height * 0.95
                        ),
                        control2: CGPoint(
                            x: rect.width * 0.55,
                            y: rect.height * 0.05
                        )
                    )
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                    path.closeSubpath()
                }
            }
        }
        private var recentlyAddedSection: some View {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Recent memories")
                        .font(MemoFont.dmSansSemiBold(20))
                        .foregroundStyle(MemoMapTheme.black)
                    Spacer()
                }
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 11))
                        .foregroundStyle(.red)
                } else if viewModel.recentMemories.isEmpty {
                    Text("Your memories will appear here.")
                        .font(.system(size: 11))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                        .padding(.vertical, 18)
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.recentMemories) { memory in
                            Button {
                                selectedMemory = memory
                            } label: {
                                memoryCard(memory)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        private func memoryCard(_ memory: Memory) -> some View {
            let photoCount = max(memory.photoBase64?.count ?? 0, 1)
            return GeometryReader { geometry in
                let cardWidth = geometry.size.width
                let imageWidth = min(max(cardWidth * 0.34, 105), 145)
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top, spacing: 5) {
                            Text(memory.title)
                                .font(MemoFont.dmSansBold(15))
                                .foregroundStyle(MemoMapTheme.black)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Spacer(minLength: 10)
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(MemoMapTheme.green)
                            Text(
                                memory.memoryDate,
                                format: .dateTime
                                    .day()
                                    .month(.abbreviated)
                                    .year()
                            )
                            .font(MemoFont.dmSansRegular(12))
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            Rectangle()
                                .fill(MemoMapTheme.inputBorder)
                                .frame(width: 1, height: 18)
                            Image(systemName: "map")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(MemoMapTheme.green)
                            Text(memory.placeName ?? "No location")
                                .font(MemoFont.dmSansRegular(12))
                                .foregroundStyle(MemoMapTheme.Textsecondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Spacer(minLength: 10)
                        if let description = memory.description,
                           !description.trimmingCharacters(
                               in: .whitespacesAndNewlines
                           ).isEmpty {
                            Text(description)
                                .font(MemoFont.dmSansRegular(13))
                                .foregroundStyle(MemoMapTheme.Textsecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                        }
                        Spacer(minLength: 10)
                        HStack(spacing: 6) {
                            Label {
                                Text(memory.category)
                                    .lineLimit(1)
                            } icon: {
                                Image(systemName: "person.2.fill")
                            }
                            .font(MemoFont.dmSansMedium(11))
                            .foregroundStyle(MemoMapTheme.green)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 8)
                            .background(
                                MemoMapTheme.lightGreen.opacity(0.3)
                            )
                            .clipShape(Capsule())
    //                        Label {
    //                            Text("\(photoCount)")
    //                        } icon: {
    //                            Image(systemName: "photo")
    //                        }
    //                        .font(MemoFont.dmSansMedium(11))
    //                        .foregroundStyle(MemoMapTheme.green)
    //                        .padding(.horizontal, 9)
    //                        .padding(.vertical, 8)
    //                        .background(
    //                            MemoMapTheme.lightGreen.opacity(0.3)
    //                        )
    //                        .clipShape(Capsule())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 100)
                    .padding(.leading, 12)
                    .padding(.vertical, 10)
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if let image = MemoryImageEncoder.decode(
                                memory.coverPhotoBase64
                            ) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Rectangle()
                                    .fill(
                                        MemoMapTheme.inputBorder.opacity(0.3)
                                    )
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.system(size: 25))
                                            .foregroundStyle(
                                                MemoMapTheme.lightGreen
                                            )
                                    }
                            }
                        }
                        .frame(width: imageWidth, height: 120)
                        .clipped()
                        Label {
                            Text("\(photoCount)")
                        } icon: {
                            Image(systemName: "photo")
                        }
                        .font(MemoFont.dmSansMedium(11))
                        .foregroundStyle(MemoMapTheme.green)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 8)
                        .background(
                            MemoMapTheme.lightGreen.opacity(0.3)
                        )
                        .clipShape(Capsule())
                        
                        
                    }
                    .frame(width: imageWidth, height: 120)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                    )
                    .padding(.trailing, 8)
                    .padding(.vertical, 10)
                }
                .frame(width: cardWidth, height: 130)
                .background {
                    LinearGradient(
                        colors: [
                            MemoMapTheme.inputBackground.opacity(0.45),
                            MemoMapTheme.inputBackground.opacity(0.85)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .stroke(
                        MemoMapTheme.inputBorder.opacity(0.3),
                        lineWidth: 0.7
                    )
                }
            }
            .frame(height: 130)
            .frame(maxWidth: .infinity)
        }
    }

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
