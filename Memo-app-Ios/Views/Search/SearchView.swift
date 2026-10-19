//
//  SearchView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-19.
//

import Combine
import Foundation
import SwiftUI
import UIKit

struct SearchView: View {

    @StateObject private var viewModel = SearchViewModel()

    var body: some View {

        GeometryReader { geometry in

            VStack(spacing: 0) {

                VStack(alignment: .leading, spacing: 16) {
                    header

                    searchBar

                    FilterSection
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 14)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)

                ScrollView(showsIndicators: false) {

                    if viewModel.isLoading {
                        LoadingView
                    } else if let error = viewModel.errorMessage {
                        errorView(error)
                    } else if viewModel.allmemories.isEmpty {
                        emptyView
                    } else {
                        ForEach(viewModel.allmemories) { memory in
                            NavigationLink {
                                MemoryDetailView(memory: memory)
                            } label: {
                                memoryCard(memory)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 14)
                .frame(maxWidth: 520)
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

        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Search memories")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(MemoMapTheme.black)

                Text("Find a memory by its story, place or date.")
                    .font(.system(size: 11))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
            }

            Spacer(minLength: 4)

            Image("LOGO")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
        }
    }

    private var searchBar: some View {
        HStack {
            TextField(
                "Search memories..",
                text: $viewModel.searchText
            )
            .font(.system(size: 13))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.search)

        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background {
            RoundedRectangle(cornerRadius: 13)
                .fill(Color.white.opacity(0.8))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .stroke(MemoMapTheme.inputBorder, lineWidth: 0.8)
        }
    }

    private var FilterSection: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Categorychip(category)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func Categorychip(_ category: String) -> some View {

        let selected = viewModel.selectedCategory == category

        return Button {
            viewModel.selectedCategory(category)
        } label: {
            Text(category)
                .font(.caption)
        }
    }

    private func memoryCard(_ memory: Memory) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 7) {
                Text(memory.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MemoMapTheme.black)
                    .lineLimit(2)

                Text(
                    memory.memoryDate,
                    format: .dateTime
                        .month(.abbreviated)
                        .day()
                        .year()
                )
                .font(.system(size: 9))
                .foregroundStyle(MemoMapTheme.Textsecondary)

                if let place = memory.placeName,
                    !place.isEmpty
                {
                    Text(place)
                        .font(.system(size: 9))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                        .lineLimit(1)
                }

                if let description = memory.description,
                    !description.isEmpty
                {
                    Text(description)
                        .font(.system(size: 10))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 13)
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
                        MemoMapTheme.inputBorder.opacity(0.3)

                        Image(systemName: "photo")
                            .foregroundStyle(
                                MemoMapTheme.Textsecondary
                            )
                    }
                }
            }
            .frame(width: 104, height: 88)
            .clipped()
        }
        .frame(height: 88)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(MemoMapTheme.inputBorder, lineWidth: 0.8)
        }
        .frame(maxWidth: .infinity)

    }

    private var LoadingView: some View {
        VStack {
            ProgressView()
            Text("Loading...")
                .font(Font.body.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 30)
    }

    private var emptyView: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 30))
                .foregroundStyle(MemoMapTheme.Textsecondary)

            Text("No memories found")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(MemoMapTheme.black)

        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.top, 35)
    }

    private func errorView(_ message: String) -> some View {

        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 28))

            Text(message)
                .font(.system(size: 12))
                .multilineTextAlignment(.center)

            Button("Try Again") {
                viewModel.stopListening()
                viewModel.startListening()
            }
            .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(MemoMapTheme.Textsecondary)
        .frame(maxWidth: .infinity)
        .padding(.top, 30)
    }

}

#Preview {
    SearchView()
    //        .EnvironmentObject(AuthViewModel)
}
