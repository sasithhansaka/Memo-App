//
//  MemoryDetailView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-19.
//

import Foundation
import SwiftUI
import UIKit

struct MemoryDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: MemoryDetailViewModel
    @State private var showDeleteConfirmation = false
    
    var onUpdate: (() -> Void)? = nil
    var onDeleted: (() -> Void)? = nil

    init(
        memory: Memory,
        onUpdate: (() -> Void)? = nil,
        onDeleted: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: MemoryDetailViewModel(memory: memory)
        )
        self.onUpdate = onUpdate
        self.onDeleted = onDeleted
    }
    
    var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 0) {

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {

                            Header

                            memoryContent
                                .padding(.horizontal, 18)
                                .padding(.top, 28)
                                .padding(.bottom, 30)
                        }
                        .frame(maxWidth: 520)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .background {
                    MemoMapTheme.background
                        .ignoresSafeArea()
                }
                .clipped()
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
        
            .alert(
                "Unable to Delete Memory",
                isPresented: $viewModel.showDeleteError
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.deleteErrorMessage ?? "Please try again.")
            }
        }
    
    private var Header: some View {
          VStack(spacing: 0) {

          
              HStack {
                  Button {
                      dismiss()
                  } label: {
                      Image(systemName: "chevron.left")
                          .font(.system(size: 18, weight: .semibold))
                          .foregroundStyle(MemoMapTheme.black)
                  }

                  Spacer()

                  Button {
                      showDeleteConfirmation = true
                  } label: {
                      if viewModel.isDeleting {
                          ProgressView()
                              .tint(.red)
                      } else {
                          Label("Delete", systemImage: "trash")
                              .font(.system(size: 12, weight: .medium))
                              .foregroundStyle(.red)
                      }
                  }
                  .disabled(viewModel.isDeleting)
                  .confirmationDialog(
                      "Delete this memory?",
                      isPresented: $showDeleteConfirmation,
                      titleVisibility: .visible
                  ) {
                      Button("Delete Memory", role: .destructive) {
                          Task {
                              let deleted = await viewModel.deleteMemory()

                              if deleted {
                                  onDeleted?()
                                  dismiss()
                              }
                          }
                      }

                      Button("Cancel", role: .cancel) {}
                  } message: {
                      Text("Are you sure you want to delete this memory?")
                  }
              }
              .padding(.horizontal, 14)
              .padding(.top, 12)
              .padding(.bottom, 6)


              if viewModel.photos.isEmpty {
                  ZStack {
                      MemoMapTheme.inputBorder.opacity(0.3)

                      Image(systemName: "photo")
                          .font(.system(size: 35))
                          .foregroundStyle(MemoMapTheme.Textsecondary)
                  }
                  .frame(height: 155)
                  .frame(maxWidth: .infinity)
                  .padding(.horizontal, 18)

              } else {
                  TabView(selection: $viewModel.selectedPhotoIndex) {
                      ForEach(
                          Array(viewModel.photos.enumerated()),
                          id: \.offset
                      ) { index, image in
                          Image(uiImage: image)
                              .resizable()
                              .scaledToFill()
                              .frame(maxWidth: .infinity)
                              .frame(height: 155)
                              .clipped()
                              .clipShape(
                                  RoundedRectangle(cornerRadius: 12)
                              )
                              .padding(.horizontal, 18)
                              .tag(index)
                      }
                  }
                  .frame(height: 165)
                  .tabViewStyle(.page(indexDisplayMode: .never))

                  HStack(spacing: 5) {
                      ForEach(
                          viewModel.photos.indices,
                          id: \.self
                      ) { index in
                          Circle()
                              .fill(
                                  viewModel.selectedPhotoIndex == index
                                      ? MemoMapTheme.background
                                      : MemoMapTheme.background.opacity(0.5)
                              )
                              .frame(width: 4, height: 4)
                      }
                  }
                  .padding(.top, 8)
                  .padding(.bottom, 10)
              }
          }
          .background {
              MemoMapTheme.inputBorder
                  .opacity(0.8)
          }
          .clipShape(
              UnevenRoundedRectangle(
                  bottomLeadingRadius: 22,
                  bottomTrailingRadius: 22
              )
          )
      }
    
    private var memoryContent: some View {
            VStack(alignment: .leading, spacing: 0) {

                Text(viewModel.memory.title)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(MemoMapTheme.black)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 5) {
//                    Text(viewModel.formattedDate)

                    Text("•")

                    Text(viewModel.locationText)
                        .lineLimit(2)
                }
                .font(.system(size: 9))
                .foregroundStyle(MemoMapTheme.Textsecondary)
                .padding(.top, 6)

                if let description = viewModel.memory.description,
                   !description.trimmingCharacters(
                        in: .whitespacesAndNewlines
                   ).isEmpty {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(MemoMapTheme.black)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 24)
                }

                // Category and OCR tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        Text(viewModel.categoryTag)
                            .font(.system(size: 9))
                            .foregroundStyle(MemoMapTheme.Textsecondary)

                        ForEach(viewModel.ocrTags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 9))
                                .foregroundStyle(MemoMapTheme.Textsecondary)
                        }
                    }
                }
                .padding(.top, 18)

                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
}

#Preview {
    NavigationStack {
        Text("Pass a real Memory instance to preview MemoryDetailView.")
    }
}
