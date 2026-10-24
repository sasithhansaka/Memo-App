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

//            Image("LOGO")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 76, height: 76)
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
            VStack(alignment: .leading, spacing: 12) {
                Text("Memory collection")
                    .font(MemoFont.dmSansSemiBold(22))
                    .foregroundStyle(MemoMapTheme.black)

                LazyVGrid(columns: columns, spacing: 8) {
                    collectionCard(
                        title: "Memories",
                        count: viewModel.totalMemories,
                        image: "memories",
                        text: "Total memories"
                    )


                    collectionCard(
                        title: "This year",
                        count: viewModel.thisYearTotal,
                        image: "Tyear",
                        text: "2026 year memories"
                    )

                     collectionCard(
                        title: "Places",
                        count: viewModel.recentMemoryCount,
                        image: "places",
                        text: "Recent memories"
                    )

                    collectionCard(
                        title: "Photos",
                        count: viewModel.photosCount,
                        image: "memories",
                        text: "Total photos collected"

                    )
                }

            }
        }

    private func collectionCard(
            title: String,
            count: Int,
            image: String,
            text: String
        ) -> some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(image)
                        .font(.system(size: 15))

                    Text(title)
                        .font(MemoFont.dmSansMedium(17))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                HStack(spacing: 5){
                Text("\(count)")
                    .font(MemoFont.dmSansRegular(22))
                    .foregroundStyle(MemoMapTheme.black)
                    .padding(.horizontal, 10)
                
//                Text(text)
//                    .font(MemoFont.dmSansRegular(12))
//                    .foregroundStyle(MemoMapTheme.Textsecondary)
                }

            }
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .background(MemoMapTheme.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(MemoMapTheme.inputBorder, lineWidth: 0.4)
            }
        }

    private var recentlyAddedSection: some View {

        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Recent memories")
                    .font(MemoFont.dmSansSemiBold(22))
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
         return HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text(memory.title)
                        .font(MemoFont.dmSansBold(17))
                        .foregroundStyle(MemoMapTheme.black)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 4){
                        
                        Label {
                            Text(
                                memory.memoryDate,
                                format: .dateTime
                                    .day()
                                    .month(.abbreviated)
                                    .year()
                            )
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(MemoFont.dmSansRegular(12))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                        .lineLimit(1)
                        
                        Label {
                            Text(memory.placeName ?? "Location not added")
                                .lineLimit(1)
                                .truncationMode(.tail)
                        } icon: {
                           Image(systemName: "mappin")
                        }
                        .font(MemoFont.dmSansRegular(12))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                    }
                    
                    if let description = memory.description,
                       !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(description)
                            .font(MemoFont.dmSansRegular(13))
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.vertical, 14)
                
             Group {
                 if let image = MemoryImageEncoder.decode(
                     memory.coverPhotoBase64
                 ) {
                     ZStack {
                         Image(uiImage: image)
                             .resizable()
                             .scaledToFill()
                             .frame(width: 120, height: 130)
                             .clipped()
                     }
                     .frame(width: 120, height: 130)
                 } else {
                     ZStack {
                         MemoMapTheme.inputBorder.opacity(0.3)

                         Image(systemName: "photo")
                             .font(.system(size: 25))
                             .foregroundStyle(MemoMapTheme.lightGreen)
                     }
                     .frame(width: 120, height: 130)
                 }
             }
             .frame(width: 120, height: 130)
             .clipShape(
                 RoundedRectangle(cornerRadius: 12, style: .continuous)
             )
             .padding(.vertical, 14)
//             .padding()
            
            }
            .frame(height: 130)
            .frame(maxWidth: .infinity)
            .background {
                LinearGradient(
                    stops: [
                        .init(
                            color: MemoMapTheme.inputBackground.opacity(0.52),
                            location: 0.0
                        ),
                        .init(
                            color: MemoMapTheme.inputBackground.opacity(1),
                            location: 1.0
                        )
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        MemoMapTheme.inputBorder.opacity(0.7),
                        lineWidth: 0.8
                    )
            }
        }

}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
