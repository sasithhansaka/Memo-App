//
//  HomeViewModelTests.swift
//  Memo-app-IosTests
//
//  Created by student3 on 2026-10-28.
//

import Testing
@testable import Memo_app_Ios

@MainActor
struct HomeViewModelTests {

    @Test
    func initialStateHasNoMemories() {
        let viewModel = HomeViewModel()

        #expect(viewModel.memories.isEmpty)
        #expect(viewModel.totalMemories == 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }


    @Test
    func totalMemoriesInitiallyEqualsZero() {
        let viewModel = HomeViewModel()

        #expect(viewModel.totalMemories == 0)
    }


    @Test
    func photosCountInitiallyEqualsZero() {
        let viewModel = HomeViewModel()

        #expect(viewModel.photosCount == 0)
    }


    @Test
    func recentMemoryCountInitiallyEqualsZero() {
        let viewModel = HomeViewModel()

        #expect(viewModel.recentMemoryCount == 0)
    }


    @Test
    func thisYearTotalInitiallyEqualsZero() {
        let viewModel = HomeViewModel()

        #expect(viewModel.thisYearTotal == 0)
    }


    @Test
    func recentMemoriesInitiallyEmpty() {
        let viewModel = HomeViewModel()

        #expect(viewModel.recentMemories.isEmpty)
    }


    @Test
    func startListeningSetsLoadingState() {
        let viewModel = HomeViewModel()

        viewModel.startListening()

        #expect(viewModel.isLoading == true)
        #expect(viewModel.errorMessage == nil)

        viewModel.stopListening()
    }
}
