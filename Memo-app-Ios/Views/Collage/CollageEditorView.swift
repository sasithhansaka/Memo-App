//
//  CollageEditorView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-26.
//

import Foundation
import SwiftUI
import UIKit


struct CollageEditorView: View {
    let photos: [UIImage]
    let template: CollageTemplate
    let background: CollageBackground
    let memory: Memory
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            VStack(spacing: 0) {
                photoLayout
                    .frame(
                        width: width,
                        height: height * 0.76
                    )
                    .clipped()
                memoryDetails
                    .frame(
                        width: width,
                        height: height * 0.24
                    )
            }
            .frame(
                width: width,
                height: height
            )
            .background(background.color)
            .clipped()
        }
        .aspectRatio(4.0 / 5.0, contentMode: .fit)
        .clipped()
    }
    @ViewBuilder
    private var photoLayout: some View {
        switch template {
        case .classicGrid:
            classicGrid
        case .memoryStory:
            memoryStory
        case .filmStrip:
            filmStrip
        case .scrapbook:
            scrapbook
        case .travelJournal:
            travelJournal
        }
    }
    private var classicGrid: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let spacing: CGFloat = 6
            let cellWidth = (width - spacing) / 2
            let cellHeight = (height - spacing) / 2
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    photo(at: 0)
                        .frame(
                            width: cellWidth,
                            height: cellHeight
                        )
                    photo(at: 1)
                        .frame(
                            width: cellWidth,
                            height: cellHeight
                        )
                }
                HStack(spacing: spacing) {
                    photo(at: 2)
                        .frame(
                            width: cellWidth,
                            height: cellHeight
                        )
                    photo(at: 3)
                        .frame(
                            width: cellWidth,
                            height: cellHeight
                        )
                }
            }
            .frame(
                width: width,
                height: height
            )
            .clipped()
        }
        .clipped()
    }
    private var memoryStory: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let spacing: CGFloat = 6
            let mainHeight = height * 0.62
            let bottomHeight = height - mainHeight - spacing
            let smallWidth = (width - spacing) / 2
            VStack(spacing: spacing) {
                photo(at: 0)
                    .frame(
                        width: width,
                        height: mainHeight
                    )
                HStack(spacing: spacing) {
                    photo(at: 1)
                        .frame(
                            width: smallWidth,
                            height: bottomHeight
                        )
                    photo(at: 2)
                        .frame(
                            width: smallWidth,
                            height: bottomHeight
                        )
                }
            }
            .frame(
                width: width,
                height: height
            )
            .clipped()
        }
        .clipped()
    }
    private var filmStrip: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let outerPadding: CGFloat = 8
            let perforationHeight: CGFloat = 14
            let photoSpacing: CGFloat = 5
            let innerWidth = width - outerPadding * 2
            let availablePhotoHeight =
                height
                - outerPadding * 2
                - perforationHeight * 2
                - photoSpacing * 3
            let photoHeight = availablePhotoHeight / 4
            VStack(spacing: 0) {
                perforations
                    .frame(height: perforationHeight)
                VStack(spacing: photoSpacing) {
                    ForEach(0..<4, id: \.self) { index in
                        photo(at: index)
                            .frame(
                                width: innerWidth,
                                height: photoHeight
                            )
                    }
                }
                .padding(.horizontal, outerPadding)
                perforations
                    .frame(height: perforationHeight)
            }
            .frame(
                width: width,
                height: height
            )
            .background(
                Color(
                    red: 0.12,
                    green: 0.14,
                    blue: 0.12
                )
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
            .clipped()
        }
        .clipped()
    }
    private var perforations: some View {
        HStack(
            spacing: 8
        ) {
            ForEach(0..<12, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.9))
                    .frame(
                        width: 10,
                        height: 5
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }
    private var scrapbook: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let cardWidth = width * 0.43
            let cardHeight = height * 0.39
            ZStack {
                Circle()
                    .fill(
                        MemoMapTheme.green.opacity(0.12)
                    )
                    .frame(width: width * 0.65)
                    .offset(
                        x: width * 0.30,
                        y: -height * 0.25
                    )
                scrapbookCard(
                    at: 0,
                    width: cardWidth,
                    height: cardHeight,
                    rotation: -6
                )
                .position(
                    x: width * 0.27,
                    y: height * 0.25
                )
                scrapbookCard(
                    at: 1,
                    width: cardWidth,
                    height: cardHeight,
                    rotation: 5
                )
                .position(
                    x: width * 0.73,
                    y: height * 0.27
                )
                scrapbookCard(
                    at: 2,
                    width: cardWidth,
                    height: cardHeight,
                    rotation: 4
                )
                .position(
                    x: width * 0.27,
                    y: height * 0.73
                )
                scrapbookCard(
                    at: 3,
                    width: cardWidth,
                    height: cardHeight,
                    rotation: -5
                )
                .position(
                    x: width * 0.73,
                    y: height * 0.73
                )
            }
            .frame(
                width: width,
                height: height
            )
            .clipped()
        }
        .clipped()
    }
    private func scrapbookCard(
        at index: Int,
        width: CGFloat,
        height: CGFloat,
        rotation: Double
    ) -> some View {
        photo(at: index)
            .frame(
                width: width - 10,
                height: height - 10
            )
            .padding(5)
            .background(.white)
            .shadow(
                color: .black.opacity(0.12),
                radius: 3,
                x: 0,
                y: 2
            )
            .rotationEffect(.degrees(rotation))
            .frame(
                width: width,
                height: height
            )
            .clipped()
    }
    private var travelJournal: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let spacing: CGFloat = 6
            let padding: CGFloat = 6
            let contentWidth = width - padding * 2
            let contentHeight = height - padding * 2
            let mainHeight = contentHeight * 0.62
            let bottomHeight =
                contentHeight - mainHeight - spacing
            let smallWidth =
                (contentWidth - spacing) / 2
            VStack(spacing: spacing) {
                photo(at: 0)
                    .frame(
                        width: contentWidth,
                        height: mainHeight
                    )
                HStack(spacing: spacing) {
                    photo(at: 1)
                        .frame(
                            width: smallWidth,
                            height: bottomHeight
                        )
                    photo(at: 2)
                        .frame(
                            width: smallWidth,
                            height: bottomHeight
                        )
                }
            }
            .padding(padding)
            .frame(
                width: width,
                height: height
            )
            .overlay {
                Rectangle()
                    .stroke(
                        MemoMapTheme.green.opacity(0.6),
                        lineWidth: 1
                    )
                    .padding(2)
            }
            .clipped()
        }
        .clipped()
    }
    private func photo(at index: Int) -> some View {
        Group {
            if !photos.isEmpty {
                Image(
                    uiImage: photos[index % photos.count]
                )
                .resizable()
                .scaledToFill()
            } else {
                Rectangle()
                    .fill(
                        MemoMapTheme.lightGreen.opacity(0.3)
                    )
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(
                                MemoMapTheme.green
                            )
                    }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .clipped()
        .clipShape(
            RoundedRectangle(
                cornerRadius: template == .scrapbook ? 2 : 7,
                style: .continuous
            )
        )
    }
    private var memoryDetails: some View {
        VStack(
            alignment: .leading,
            spacing: 5
        ) {
            Text(memory.title)
                .font(
                    MemoFont.dmSansSemiBold(18)
                )
                .foregroundStyle(detailTextColor)
                .lineLimit(2)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            if let location = memory.placeName,
               !location.trimmingCharacters(
                    in: .whitespacesAndNewlines
               ).isEmpty {
                Label(
                    location,
                    systemImage: "mappin.and.ellipse"
                )
                .font(
                    MemoFont.dmSansRegular(11)
                )
                .foregroundStyle(
                    detailTextColor.opacity(0.8)
                )
                .lineLimit(1)
            }
            if let description = memory.description,
               !description.trimmingCharacters(
                    in: .whitespacesAndNewlines
               ).isEmpty {
                Text(description)
                    .font(
                        MemoFont.dmSansRegular(11)
                    )
                    .foregroundStyle(
                        detailTextColor.opacity(0.9)
                    )
                    .lineLimit(3)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(background.color)
        .clipped()
    }
    private var detailTextColor: Color {
        background == .dark
            ? .white
            : MemoMapTheme.black
    }
}
