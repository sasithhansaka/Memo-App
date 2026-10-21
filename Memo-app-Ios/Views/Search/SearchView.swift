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
//                    .padding(.horizontal, 18)
//                    .padding(.top, 16)
//                    .padding(.bottom, 14)
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

            .background {
                MemoMapTheme.background
                    .ignoresSafeArea()
            }
            .clipped()
        }
//        .ignoresSafeArea(edges: .top)

        .navigationBarBackButtonHidden(true)

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
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(MemoMapTheme.black)
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                
                    Text("Search memories")
                    .font(MemoFont.dmSansRegular(34))                    .foregroundStyle(MemoMapTheme.black)

                    Text("Find a memory by its story, place or date.")
                    .font(MemoFont.dmSansRegular(15))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom , 10)
            Spacer(minLength: 2)
            

//            Image("LOGO")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 76, height: 76)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }

    private var searchBar: some View {
        HStack() {
        Image("search")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(MemoMapTheme.Textsecondary)
        
        
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
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Categorychip(category)
                }
            }
//            .padding(.vertical, 0)
//            .padding(.horizontal, 1)
            .padding(.top ,8)
            .padding(.bottom ,20)
            
        }
    }

    private func Categorychip(_ category: String) -> some View {

        let selected = viewModel.selectedCategory == category

        return Button {
            viewModel.selectedCategory(category)
        } label: {
            Text(category)
                .font(.system(size: 13, weight: .medium))
                   .foregroundStyle(
                       MemoMapTheme.green
                   )
                   .padding(.horizontal, 15)
                   .frame(height: 36)
                   .background(
                       selected
                       ? MemoMapTheme.lightGreen
                       : MemoMapTheme.lightGreen
                   )
                 .clipShape(RoundedRectangle(cornerRadius: 20))
                   .overlay {
                       RoundedRectangle(cornerRadius: 20)
                           .stroke(
                               selected
                                   ? MemoMapTheme.inputBorder.opacity(0.8)
                                   : Color.clear,
                               lineWidth: 1.2
                           )
                   }
        }
    }

    private func memoryCard(_ memory: Memory) -> some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 7) {
                 Text(memory.title)
                     .font(.system(size: 15, weight: .semibold))
                     .foregroundStyle(MemoMapTheme.black)
                     .lineLimit(2)
                     .multilineTextAlignment(.leading)

                 HStack(spacing: 4) {
                     Text(memory.memoryDate, format: .dateTime
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
             .padding(.vertical , 15)
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
