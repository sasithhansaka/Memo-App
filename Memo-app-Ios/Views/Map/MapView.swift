//
//  MapView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-02.
//


import Foundation
import SwiftUI
import MapKit
import UIKit

struct MemoryMapView: View {

    @StateObject private var viewModel = MemoryMapViewModel()

    var body: some View {

        GeometryReader { geometry in
            VStack(spacing: 0) {

                header

                ZStack(alignment: .bottom) {
                    mapContent
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height  * 0.80
                        )
                        .clipped()

                    if let memory = viewModel.selectedMemory {
                        memoryPreview(memory)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 14)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 15)
            .padding(.top, 25)
            .padding(.bottom, 24)
//            .frame(maxWidth: 520)
//            .frame(maxWidth: .infinity)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .background(MemoMapTheme.background)
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
                Text("Google Map")
                    .font(MemoFont.dmSansRegular(34))
                    .foregroundStyle(MemoMapTheme.black)
                Text("Explore your moments by place.")
                    .font(MemoFont.dmSansRegular(15))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom , 25)
    }

    private var mapContent: some View {

        Map(position: $viewModel.cameraPosition) {

            ForEach(viewModel.memoriesWithLocations) { memory in

                Annotation(
                    memory.title,
                    coordinate: CLLocationCoordinate2D(
                        latitude: memory.latitude,
                        longitude: memory.longitude
                    ),

                    anchor: .bottom
                ) {

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.selectMemory(memory)
                        }
                    } label: {
                        Circle()
                            .fill(Color.clear)
                            .frame(
                                width: viewModel.selectedMemoryID == memory.id ? 24 : 18,
                                height: viewModel.selectedMemoryID == memory.id ? 24 : 18
                            )
                            .overlay {
                                Circle()
                                    .strokeBorder(
                                        MemoMapTheme.green.opacity(
                                            viewModel.selectedMemoryID == memory.id ? 1.0 : 0.7
                                        ),
                                        lineWidth: 5
                                    )
                            }
                            .padding(6)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(memory.title)
                    .accessibilityHint("Show this memory on the map")
                }
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading memories...")
                    .padding(16)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                    Text(error)
                        .font(.caption)
                        .multilineTextAlignment(.center)

                    Button("Retry") {
                        viewModel.stopListening()
                        viewModel.startListening()
                    }
                    .font(.caption.weight(.semibold))
                }
                .padding(16)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding()
            } else if viewModel.memoriesWithLocations.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "map")
                        .font(.title2)

                    Text("No memory locations yet")
                        .font(.headline)

                    Text("Add a location when creating a memory to see it here.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                .padding(18)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()

            }
        }
    }
    
    private func memoryPreview(_ memory: Memory) -> some View {
        let photoCount = max(memory.photoBase64?.count ?? 0, 1)
        return GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let imageWidth = min(max(cardWidth * 0.34, 105), 145)
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 5) {
                        Text(memory.title)
                            .font(MemoFont.dmSansBold(16))
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
                    .frame(width: imageWidth, height: 110)
                    .clipped()
                    
                }
                .frame(width: imageWidth, height: 110)
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

//    private func memoryPreview(_ memory: Memory) -> some View {
//        HStack(spacing: 0) {
//            VStack(alignment: .leading, spacing: 7) {
//                 Text(memory.title)
//                     .font(.system(size: 15, weight: .semibold))
//                     .foregroundStyle(MemoMapTheme.black)
//                     .lineLimit(2)
//                     .multilineTextAlignment(.leading)
//
//                 HStack(spacing: 4) {
//                     Text(memory.memoryDate, format: .dateTime
//                         .month(.abbreviated)
//                         .day()
//                         .year()
//                     )
//
//                     Text("•")
//
//                     Text(memory.placeName ?? "Location not added")
//                         .lineLimit(1)
//                 }
//                 .font(.system(size: 13))
//                 .foregroundStyle(MemoMapTheme.Textsecondary)
//             }
//             .frame(maxWidth: .infinity, alignment: .leading)
//             .padding(.leading, 12)
//             .padding(.vertical, 12)
//
//             Group {
//                 if let image = MemoryImageEncoder.decode(
//                     memory.coverPhotoBase64
//                 ) {
//                     Image(uiImage: image)
//                         .resizable()
//                         .scaledToFill()
//                 } else {
//                     ZStack {
////                         MemoMapTheme.inputBorder.opacity(0.3)
//
//                         Image(systemName: "photo")
//                             .foregroundStyle(MemoMapTheme.Textsecondary)
//                     }
//                 }
//             }
//             .frame(width: 110, height: 78)
//             .padding(.vertical , 15)
//             .clipped()
//         }
//         .frame(height: 78)
//         .background(MemoMapTheme.inputBackground)
//         .clipShape(RoundedRectangle(cornerRadius: 12))
//         .overlay {
//             RoundedRectangle(cornerRadius: 12)
//                 .stroke(MemoMapTheme.inputBorder, lineWidth: 0.8)
//         }
//         .frame(maxWidth: .infinity)
//    }
}

#Preview {
    MemoryMapView()
}
