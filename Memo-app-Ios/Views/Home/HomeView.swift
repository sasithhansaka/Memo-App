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

                        // Add these sections when ready:
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
                    .font(MemoFont.dmSansRegular(34))                    .foregroundStyle(MemoMapTheme.black)

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
        GeometryReader { geometry in
            let cardWidth = geometry.size.width

            VStack(alignment: .leading, spacing: 0) {

//                Text("A memory nearby")
//                    .font(MemoFont.dmSansSemiBold(18))
//                    .foregroundStyle(MemoMapTheme.black)
//                    .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 0) {

                    Image("university")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: 140)
                        .clipped()

                    VStack(alignment: .leading, spacing: 4) {

                        Text("University Exhibition")
                            .font(MemoFont.dmSansBold(26))
                            .foregroundStyle(MemoMapTheme.White)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        HStack(alignment: .center, spacing: 8) {

                            Text("120 m away")

                            Circle()
                                .fill(.white)
                                .frame(width: 5, height: 5)

                            Text("Sep 25, 2024")

                            Spacer(minLength: 4)

                            Button {
                            } label: {
                                Text("View memory")
                                    .underline()
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                            }
                            .buttonStyle(.plain)
                        }
                        .font(MemoFont.dmSansMedium(16))
                        .foregroundStyle(MemoMapTheme.White)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom,24)
                }
                .frame(width: cardWidth)
                .background(MemoMapTheme.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(width: cardWidth, alignment: .leading)
        }
        .frame(height: 220)
        .padding(.bottom, 20)
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
                            .frame(width: 45, height: 45)

                        Image("Search Icon")
                            .resizable()
                            .frame(width: 20, height: 20)

                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Find all memories")
                            .font(MemoFont.dmSansMedium(19))
//                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(MemoMapTheme.black)

                        Text("Search by place, category or story")
                            .font(MemoFont.dmSansRegular(15))
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(MemoMapTheme.green)

                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MemoMapTheme.White)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MemoMapTheme.inputBorder, lineWidth: 0.6)
                }
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var collectionBanner: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Your memory collection")
                .font(MemoFont.dmSansSemiBold(22))
                .foregroundStyle(MemoMapTheme.black)

            LazyVGrid(columns: columns, spacing: 8) {
                collectionCard(
                    title: "Memories",
                    count: viewModel.totalMemories,
                    image: "memories"
                )

                collectionCard(
                    title: "Places",
                    count: viewModel.recentMemoryCount,
                    image: "memories"
                )

                collectionCard(
                    title: "This year",
                    count: viewModel.thisYearTotal,
                    image: "memories"
                )
            }

        }
    }

    private func collectionCard(
        title: String,
        count: Int,
        image: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(image)
                    .font(.system(size: 15))

                Text(title)
                    .font(MemoFont.dmSansMedium(17))
//                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Text("\(count)")
                .font(MemoFont.dmSansRegular(22))
//                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(MemoMapTheme.black)
                .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(MemoMapTheme.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(MemoMapTheme.inputBorder, lineWidth: 0.6)
        }
    }

    private var recentlyAddedSection: some View {

        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Recently added")
                    .font(MemoFont.dmSansSemiBold(22))
                    .foregroundStyle(MemoMapTheme.black)

                Spacer()

                //               NavigationLink("See all") {
                //                   SearchView()
                //               }
                //               .font(.system(size: 10, weight: .medium))
                //               .foregroundStyle(MemoMapTheme.Textsecondary)
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
                VStack(spacing: 12) {
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
//                Text(memory.category)
//                    .font(MemoFont.dmSansMedium(11))
//                    .foregroundStyle(MemoMapTheme.green)
//                    .padding(.horizontal, 5)
//                    .padding(.vertical, 5)
//                    .background(
//                        Capsule()
//                            .fill(MemoMapTheme.lightGreen)
//                    )
                
                Text(memory.title)
                    .font(MemoFont.dmSansBold(15))
                    .foregroundStyle(MemoMapTheme.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 6){
                    
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
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .font(MemoFont.dmSansRegular(12))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                }
                
                if let description = memory.description,
                   !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(description)
                        .font(MemoFont.dmSansMedium(14))
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
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        //                         MemoMapTheme.inputBorder.opacity(0.3)
                        
                        Image(systemName: "photo")
                            .font(.system(size: 25))
                        .foregroundStyle(MemoMapTheme.lightGreen)                    }
                }
            }
            .frame(width: 120, height: 150)
            .padding(.vertical, 15)
            .clipped()
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 20
                )
            )
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(MemoMapTheme.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        overlay {
            RoundedRectangle(cornerRadius: 20)
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
