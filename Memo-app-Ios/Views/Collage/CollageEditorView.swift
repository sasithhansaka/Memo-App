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
            let padding: CGFloat = 12
            let spacing: CGFloat = 8

            let contentWidth = width - padding * 2
            let contentHeight = height - padding * 2

            let topHeight = contentHeight * 0.68
            let bottomHeight = contentHeight - topHeight - spacing
            let accentWidth: CGFloat = 5

            VStack(spacing: spacing) {
                ZStack(alignment: .bottomLeading) {
                    photo(at: 0)
                        .frame(
                            width: contentWidth,
                            height: topHeight
                        )
                        .clipped()

                    LinearGradient(
                        colors: [
                            .clear,
                            .black.opacity(0.65)
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("A MOMENT TO REMEMBER")
                            .font(MemoFont.dmSansSemiBold(9))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.9))

                        Text(memory.title)
                            .font(MemoFont.dmSansSemiBold(18))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                    .padding(12)
                }
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 5,
                        style: .continuous
                    )
                )

                HStack(spacing: spacing) {
                    Rectangle()
                        .fill(MemoMapTheme.green)
                        .frame(width: accentWidth)

                    photo(at: 1)
                        .frame(
                            width: (contentWidth - accentWidth - spacing * 2) * 0.58,
                            height: bottomHeight
                        )
                        .clipped()

                    photo(at: 2)
                        .frame(
                            width: (contentWidth - accentWidth - spacing * 2) * 0.42,
                            height: bottomHeight
                        )
                        .clipped()
                }
            }
            .padding(padding)
            .frame(width: width, height: height)
            .background(background.color)
            .clipped()
        }
        .clipped()
    }
    

    private var memoryStory: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let spacing: CGFloat = 6

            let leftWidth = (width - spacing) * 0.62
            let rightWidth = width - leftWidth - spacing

            let smallHeight = (height - spacing * 2) / 3

            HStack(spacing: spacing) {

                // Main photo
                photo(at: 0)
                    .frame(
                        width: leftWidth,
                        height: height
                    )

                // Three supporting photos
                VStack(spacing: spacing) {

                    photo(at: 1)
                        .frame(
                            width: rightWidth,
                            height: smallHeight
                        )

                    photo(at: 2)
                        .frame(
                            width: rightWidth,
                            height: smallHeight
                        )

                    photo(at: 3)
                        .frame(
                            width: rightWidth,
                            height: smallHeight
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

            let railWidth: CGFloat = 16
            let padding: CGFloat = 10
            let spacing: CGFloat = 7

            let contentWidth = width - railWidth * 2 - padding * 2
            let contentHeight = height - padding * 2

            let heroHeight = contentHeight * 0.67
            let thumbnailHeight = contentHeight - heroHeight - spacing
            let thumbnailWidth = (contentWidth - spacing * 2) / 3

            HStack(spacing: 0) {
//                filmPerforationRail
//                    .frame(width: railWidth)

                VStack(spacing: spacing) {
                    ZStack(alignment: .bottomLeading) {
                        photo(at: 0)
                            .frame(
                                width: contentWidth,
                                height: heroHeight
                            )
                            .clipped()

                        LinearGradient(
                            colors: [
                                .clear,
                                .black.opacity(0.75)
                            ],
                            startPoint: .center,
                            endPoint: .bottom
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("FRAME 001")
                                .font(MemoFont.dmSansSemiBold(8))
                                .tracking(2)
                                .foregroundStyle(.white.opacity(0.8))

                            Text(memory.title)
                                .font(MemoFont.dmSansSemiBold(15))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                        }
                        .padding(9)
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 3)
                    )

                    HStack(spacing: spacing) {
                        photo(at: 1)
                            .frame(
                                width: thumbnailWidth,
                                height: thumbnailHeight
                            )
                            .clipped()

                        photo(at: 2)
                            .frame(
                                width: thumbnailWidth,
                                height: thumbnailHeight
                            )
                            .clipped()

                        photo(at: 3)
                            .frame(
                                width: thumbnailWidth,
                                height: thumbnailHeight
                            )
                            .clipped()
                    }
                }
                .padding(padding)

//                filmPerforationRail
//                    .frame(width: railWidth)
            }
            .frame(width: width, height: height)
            .background(
                Color(red: 0.08, green: 0.09, blue: 0.09)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        Color.white.opacity(0.15),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
            .clipped()
        }
        .clipped()
    }
    
    private var filmPerforationRail: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0..<12, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.9))
                        .frame(
                            width: 9,
                            height: 5
                        )

                    Spacer(minLength: 0)
                }
            }
            .padding(.vertical, 5)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
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

            ZStack {

                Circle()
                    .fill(
                        MemoMapTheme.green.opacity(0.12)
                    )
                    .frame(width: width * 0.65)
                    .offset(
                        x: width * 0.38,
                        y: -height * 0.38
                    )

                Circle()
                    .fill(
                        Color.orange.opacity(0.10)
                    )
                    .frame(width: width * 0.45)
                    .offset(
                        x: -width * 0.40,
                        y: height * 0.40
                    )

                scrapbookCard(
                    at: 0,
                    width: width * 0.61,
                    height: height * 0.56,
                    rotation: -7
                )
                .position(
                    x: width * 0.39,
                    y: height * 0.39
                )
                .zIndex(1)

                scrapbookCard(
                    at: 1,
                    width: width * 0.35,
                    height: height * 0.35,
                    rotation: 8
                )
                .position(
                    x: width * 0.77,
                    y: height * 0.25
                )
                .zIndex(2)

                scrapbookCard(
                    at: 2,
                    width: width * 0.40,
                    height: height * 0.36,
                    rotation: -5
                )
                .position(
                    x: width * 0.69,
                    y: height * 0.72
                )
                .zIndex(3)

                Rectangle()
                    .fill(
                        Color.yellow.opacity(0.65)
                    )
                    .frame(
                        width: width * 0.18,
                        height: 12
                    )
                    .rotationEffect(.degrees(-7))
                    .position(
                        x: width * 0.39,
                        y: height * 0.115
                    )
                    .zIndex(4)

                Image(systemName: "sparkles")
                    .font(
                        .system(
                            size: 23,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        MemoMapTheme.green
                    )
                    .rotationEffect(.degrees(12))
                    .position(
                        x: width * 0.16,
                        y: height * 0.79
                    )
                    .zIndex(5)
            }
            .frame(
                width: width,
                height: height
            )
            .background(
                background.color
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

        VStack(spacing: 0) {

            // Photo inside the Polaroid frame
            photo(at: index)
                .frame(
                    width: width - 14,
                    height: height - 34
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 2
                    )
                )

            // Polaroid-style white caption area
            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 7))

                Text("MEMORIES")
                    .font(
                        MemoFont.dmSansSemiBold(7)
                    )
                    .tracking(1)
            }
            .foregroundStyle(
                MemoMapTheme.green.opacity(0.9)
            )
            .padding(.bottom, 5)
        }
        .frame(
            width: width,
            height: height
        )
        .background(Color.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 3
            )
        )
        .shadow(
            color: .black.opacity(0.20),
            radius: 7,
            x: 0,
            y: 4
        )
        .rotationEffect(
            .degrees(rotation)
        )
    }
    

    private var travelJournal: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            let padding: CGFloat = 12
            let spacing: CGFloat = 8

            let contentWidth = width - padding * 2
            let contentHeight = height - padding * 2

            let headerHeight = contentHeight * 0.17
            let photoHeight = contentHeight - headerHeight - spacing

            ZStack {
                background.color

                VStack(alignment: .leading, spacing: spacing) {

                    HStack(alignment: .center, spacing: 8) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("POSTCARD FROM")
                                .font(MemoFont.dmSansSemiBold(8))
                                .tracking(2)
                                .foregroundStyle(MemoMapTheme.green)

                            Text(memory.placeName ?? "YOUR JOURNEY")
                                .font(MemoFont.dmSansSemiBold(16))
                                .foregroundStyle(detailTextColor)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 4)

                        Image(systemName: "location.north.circle")
                            .font(.system(size: 28))
                            .foregroundStyle(MemoMapTheme.green)
                    }
                    .frame(height: headerHeight)

                    ZStack(alignment: .bottomTrailing) {
                        photo(at: 0)
                            .frame(
                                width: contentWidth,
                                height: photoHeight
                            )
                            .clipped()

                        Text("Frame 001")
                            .font(MemoFont.dmSansSemiBold(8))
                            .tracking(1)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 6)
                            .background(MemoMapTheme.green)
                            .padding(8)
                    }
                    .frame(
                        width: contentWidth,
                        height: photoHeight
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 4,
                            style: .continuous
                        )
                    )
                }
                .padding(padding)

                VStack {
                    HStack {
                        Spacer()

                        Image(systemName: "seal")
                            .font(.system(size: 30))
                            .foregroundStyle(
                                MemoMapTheme.green.opacity(0.8)
                            )
                    }

                    Spacer()
                }
                .padding(.top, padding + 2)
                .padding(.trailing, padding + 2)
                .allowsHitTesting(false)
            }
            .frame(width: width, height: height)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        MemoMapTheme.green.opacity(0.6),
                        lineWidth: 1.5
                    )
                    .padding(4)
                    .allowsHitTesting(false)
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
                    systemImage: "map"
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
        switch background {
        case .dark, .midnightNavy, .darkForestGreen:
            return .white

        default:
            return MemoMapTheme.black
        }
    }
}
