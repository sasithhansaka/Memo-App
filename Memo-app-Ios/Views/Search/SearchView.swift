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
    @Environment(\.dismiss) private var dismiss

    var body: some View {

        GeometryReader { geometry in
            

            VStack(spacing: 0) {

                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        header

                        searchBar

                        FilterSection
                    }
                    
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity)

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
                            .padding(.bottom, 8)
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
                .padding(.bottom, 0)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .top
            )
        }

        .background {
            MemoMapTheme.background
                .ignoresSafeArea()
        }
        .clipped()
        
         .navigationBarBackButtonHidden(true)
         .toolbarBackground(.hidden, for: .navigationBar)
        .tint(MemoMapTheme.green)
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
}

    }
    

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(MemoMapTheme.green.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .background(MemoMapTheme.White.opacity(0.6))
                    .clipShape(Circle())
                    .padding(.top,5)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Go back")

            VStack(alignment: .leading, spacing: 6) {
                Text("Search memories")
                    .font(MemoFont.dmSansRegular(30))
                    .foregroundStyle(MemoMapTheme.black)

                Text("Find a memory by its story, place or date.")
                    .font(MemoFont.dmSansRegular(15))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
        Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(MemoMapTheme.Textsecondary)
        
        
        TextField(
            "Search memories..",
            text: $viewModel.searchText
        )
        .font(MemoFont.dmSansRegular(17))
        .foregroundStyle(MemoMapTheme.black)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .submitLabel(.search)


         if !viewModel.searchText.isEmpty {
            Button {
                viewModel.searchText = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        MemoMapTheme.Textsecondary.opacity(0.65)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Clear search")
        }

        }
        .padding(.horizontal, 14)
        
        .frame(height: 48)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(MemoMapTheme.inputBorder, lineWidth: 0.6)
        }
    }

    private var FilterSection: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Categorychip(category)
                }
            }
           .padding(.vertical, 1)
           .padding(.horizontal, 6)
           .padding(.bottom, 10)
        }
    }

    private func Categorychip(_ category: String) -> some View {

        let selected = viewModel.selectedCategory == category

        return Button {
            viewModel.selectedCategory(category)
        } label: {
             HStack(spacing: 7) {
            if let symbol = categorySymbol(for: category) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
            }

            Text(category)
                .font(MemoFont.dmSansMedium(16))
                .fixedSize()
            }

            .foregroundStyle(
            selected ? Color.white : MemoMapTheme.green
            )
            .padding(.horizontal, 16)
            .frame(height: 42)
            .background {
                Capsule()
                    .fill(
                        selected
                            ? MemoMapTheme.green
                            : Color.white.opacity(0.55)
                    )
            }
            .overlay {
                Capsule()
                    .stroke(
                        selected
                            ? MemoMapTheme.green
                            : MemoMapTheme.inputBorder.opacity(0.45),
                        lineWidth: 1
                    )
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func categorySymbol(for category: String) -> String? {
        switch category {
        case "All":
            return nil
        case "Travels":
            return "airplane"
        case "Family":
            return "house"
        case "University & Education":
            return "graduationcap"
        case "Friends":
            return "person.2"
        case "Other":
            return "square.grid.2x2"
        default:
            return nil
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
                            .font(MemoFont.dmSansBold(17))
                            .foregroundStyle(MemoMapTheme.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer(minLength: 10)
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(MemoMapTheme.Textsecondary.opacity(0.9))
                        
                        Text(
                            memory.memoryDate,
                            format: .dateTime
                                .day()
                                .month(.abbreviated)
                                .year()
                        )
                        .font(MemoFont.dmSansRegular(14))
                        .foregroundStyle(MemoMapTheme.Textsecondary.opacity(0.9))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        
                        Rectangle()
                            .fill(MemoMapTheme.inputBorder)
                            .frame(width: 1, height: 18)
                        
                        Image(systemName: "map")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                        
                        
                        Text(memory.placeName ?? "No location")
                            .font(MemoFont.dmSansRegular(14))
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                    }
                    Spacer(minLength: 10)
                    
                    HStack(spacing: 6) {
                        Label {
                            Text(memory.category)
                                .lineLimit(1)
                        } icon: {
                            Image(systemName: "person.2.fill")
                        }
                        .font(MemoFont.dmSansMedium(14))
                        .foregroundStyle(MemoMapTheme.green)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 8)
                        .background(
                            MemoMapTheme.lightGreen.opacity(0.3)
                        )
                        .clipShape(Capsule())
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
            .frame(width: cardWidth, height: 140)
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
        .frame(height: 140)
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
