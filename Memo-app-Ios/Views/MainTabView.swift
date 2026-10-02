//
//  MainTabView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-02.
//

import SwiftUI


enum tabs{
    case home
    case map
    case profile
    case add
    case timeline
}


struct MainTabView: View {
    
    @State private var tab: tabs = .home
    
    var body : some View{
        ZStack(alignment: .bottom){
            Group{
            switch tab {
                case .home: HomeView()
                    
                case .map: MapView()
                    
                case .add: AddMemoryView()
                    
                case .timeline: TimelineView()
                    
                case .profile: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            MainTabBar(tab : $tab)
            .padding(.bottom, 10)
            .padding(.horizontal,  18)
        }
        .background(
            MemoMapTheme.background
                .ignoresSafeArea()
        )
    }
}

struct MainTabBar: View{
    @Binding var tab: tabs

    var body: some View {

            HStack(spacing: 0) {

                navigationItem(
                    tab: .home,
                    title: "Home",
                    icon: "house"
                )

                navigationItem(
                    tab: .map,
                    title: "Map",
                    icon: "location"
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
            .frame(height: 58)
            .padding(.horizontal, 4)
            .background(
                MemoMapTheme.inputBackground
            )
            .clipShape(
                Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(
                        MemoMapTheme.inputBorder,
                        lineWidth: 1
                    )
            )
        }
        private func navigationItem(
            tab: tabs,
                title: String,
                icon: String
            ) -> some View {

                Button {

                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.tab = tab
                    }

                } label: {

                    VStack(spacing: 3) {

                        Image(systemName: icon)
                            .font(
                                .system(
                                    size: 17,
                                    weight:self.tab == tab
                                        ? .medium
                                        : .regular
                                )
                            )

                        Text(title)
                            .font(
                                .system(
                                    size: 9,
                                    weight: self.tab == tab
                                        ? .semibold
                                        : .regular
                                )
                            )
                    }
                    .foregroundStyle(
                        self.tab == tab
                            ? MemoMapTheme.green
                        : MemoMapTheme.Textsecondary
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background {

                        if self.tab == tab {

                            Capsule()
//                                .fill(
//                                    MemoMapTheme.green                                )
                                .fill(MemoMapTheme.green.opacity(0.20))
                                .padding(.horizontal, 3)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
}

#Preview{
    
    MainTabView()
}
