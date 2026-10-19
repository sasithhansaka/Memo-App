//
//  HomeView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//

import Combine
import Foundation
import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel
        @StateObject private var viewModel = HomeViewModel()

        @State private var selectedMemory: Memory?

        private let columns = [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ]

        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 0) {

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 23) {

                            header

                            findMemoriesCard

                            collectionSection

                            recentlyAddedSection
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                        .frame(maxWidth: 520)
                        .frame(maxWidth: .infinity)
                    }
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
            .navigationDestination(item: $selectedMemory) { memory in
                MemoryDetailView(
                    memory: memory,
                    onDeleted: {
                        selectedMemory = nil
                    }
                )
            }
            .onAppear {
                viewModel.startListening()
            }
            .onDisappear {
                viewModel.stopListening()
            }
        }



#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
