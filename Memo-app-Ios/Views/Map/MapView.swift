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
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    .background(MemoMapTheme.background)

                ZStack(alignment: .bottom) {
                    mapContent
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                                - headerHeight
                        )
                        .clipped()

                    // Selected memory preview
                    if let memory = viewModel.selectedMemory {
                        memoryPreview(memory)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 14)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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

    private var headerHeight: CGFloat {
        104
    }


    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Memory Map")
                    .font(.system(size: 28, weight: .bold))
                    .tracking(-0.6)
                    .foregroundStyle(MemoMapTheme.black)

                Text("Explore your moments by place.")
                    .font(.system(size: 12))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
            }

            Spacer(minLength: 8)

                ZStack {
                    Image("LOGO")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: 100,
                            height: 100
                        )
                }
                .frame(width: 76, height: 76)
        }
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
                        VStack(spacing: 2) {
                            Image(
                                systemName:
                                    viewModel.selectedMemoryID == memory.id
                                    ? "mappin.circle.fill"
                                    : "mappin.circle"
                            )
                            .font(
                                .system(
                                    size: viewModel.selectedMemoryID == memory.id
                                        ? 34 : 28
                                )
                            )
                            .foregroundStyle(
                                viewModel.selectedMemoryID == memory.id
                                    ? Color.green
                                    : Color.red
                            )
                            .shadow(color: .black.opacity(0.2), radius: 3)

                            Circle()
                                .fill(.black.opacity(0.18))
                                .frame(width: 7, height: 3)
                        }
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

        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text(memory.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(MemoMapTheme.black)
                    .lineLimit(2)

                Text(
                    memory.placeName?.isEmpty == false
                        ? memory.placeName!
                        : "Location saved"
                )
                .font(.system(size: 11))
                .foregroundStyle(MemoMapTheme.Textsecondary)
                .lineLimit(2)

                Text(
                    memory.memoryDate,
                    format: .dateTime.month(.abbreviated).day()
                )
                .font(.system(size: 11))
                .foregroundStyle(MemoMapTheme.Textsecondary)
            }

            Spacer(minLength: 0)

            Group {
                if let image = MemoryImageEncoder.decode(
                    memory.coverPhotoBase64
                ) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        MemoMapTheme.inputBorder.opacity(0.4)

                        Image(systemName: "photo")
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                    }
                }
            }
            .frame(width: 88, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(12)
        .background(MemoMapTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(MemoMapTheme.inputBorder, lineWidth: 0.8)
        }
        
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)

        .frame(maxWidth: 440)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MemoryMapView()
}
