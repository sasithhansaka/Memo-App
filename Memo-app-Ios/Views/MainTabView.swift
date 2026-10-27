//
//  MainTabView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-02.
//

import SwiftUI

enum Tabs {
    case home
    case map
    case add
    case timeline
    case profile
}

struct MainTabView: View {

    @State private var tab: Tabs = .home

    var body: some View {
        NavigationStack {
            Group {
                switch tab {

                case .home:
                    HomeView()

                case .map:
                    MemoryMapView()

                case .add:
                    AddMemoryView()

                case .timeline:
                    TimelineView()

                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                MemoMapTheme.background
                    .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomNavigationBar
            }
        }
    }
    

    private var bottomNavigationBar: some View {

        HStack(spacing: 0) {

            navigationItem(
                tab: .home,
                title: "Home",
                icon: "house"
            )

            navigationItem(
                tab: .map,
                title: "Map",
                icon: "map"
            )

            navigationItem(
                tab: .add,
                title: "Add",
                icon: "plus"
            )

            navigationItem(
                tab: .timeline,
                title: "Timeline",
                icon: "clock"
            )

            navigationItem(
                tab: .profile,
                title: "Profile",
                icon: "person"
            )
        }
        .frame(height: 62)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.top, 4)
        .padding(.bottom, 4)
        .background {
            MemoMapTheme.background
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(MemoMapTheme.inputBorder.opacity(0.2))
                .frame(height: 1)
        }
    }

    private func navigationItem(
        tab: Tabs,
        title: String,
        icon: String
    ) -> some View {

        Button {
            guard self.tab != tab else { return }

            var transaction = Transaction()
            transaction.animation = nil

            withTransaction(transaction) {
                self.tab = tab
            }
            
        } label: {

            VStack(spacing: 3) {

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 20,
                            weight: self.tab == tab
                                ? .medium
                                : .regular
                        )
                    )

                Text(title)
                    .font(
                        self.tab == tab
                            ? MemoFont.dmSansMedium(12)
                            : MemoFont.dmSansMedium(10)
                    )
            }
            .foregroundStyle(
                self.tab == tab
                    ? MemoMapTheme.green
                    : MemoMapTheme.Textsecondary
            )
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {

                if self.tab == tab {
                    Capsule()
                        .fill(
                            MemoMapTheme.green.opacity(0.20)
                        )
                        .padding(.horizontal, 3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
