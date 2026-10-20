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
        GridItem(.flexible()),
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
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(MemoMapTheme.black)

                Text("Your memories are waiting to be rediscovered.")
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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(MemoMapTheme.black)

                        Text("Search by place, category or story")
                            .font(.system(size: 14))
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(MemoMapTheme.green)

                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MemoMapTheme.White)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MemoMapTheme.inputBorder, lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var collectionBanner: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your memory collection")
                .font(.system(size: 17, weight: .semibold))
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
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Text("\(count)")
                .font(.system(size: 21, weight: .bold))
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
                .stroke(MemoMapTheme.inputBorder, lineWidth: 1)
        }
    }

    private var recentlyAddedSection: some View {

        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recently added")
                    .font(.system(size: 17, weight: .semibold))
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
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 7) {
                Text(memory.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(MemoMapTheme.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 4) {
                    Text(
                        memory.memoryDate,
                        format: .dateTime
                            .month(.abbreviated)
                            .day()
                            .year()
                    )

                    Text("•")

                    Text(memory.placeName ?? "Location not added")
                        .lineLimit(1)
                }
                .font(.system(size: 13))
                .foregroundStyle(MemoMapTheme.Textsecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
            .padding(.vertical, 12)

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
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                    }
                }
            }
            .frame(width: 110, height: 78)
            .padding(.vertical, 15)
            .clipped()
        }
        .frame(height: 78)
        .background(MemoMapTheme.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(MemoMapTheme.inputBorder, lineWidth: 0.8)
        }
        .frame(maxWidth: .infinity)
    }

}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
