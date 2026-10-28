//
//  profileTestcases.swift
//  Memo-app-IosTests
//
//  Created by student3 on 2026-10-28.
//

import Testing
import FirebaseAuth
@testable import Memo_app_Ios

@MainActor
struct profileTestcases {

    @Test
        func initialFullNameIsEmpty() {
            let viewModel = AuthViewModel()

            #expect(viewModel.fullName == "")
        }

        @Test
        func initialLoadingStateIsFalse() {
            let viewModel = AuthViewModel()

            #expect(viewModel.isLoading == false)
        }

        @Test
        func userMatchesCurrentFirebaseAuthenticationState() {
            let viewModel = AuthViewModel()

            #expect(
                viewModel.user?.uid == Auth.auth().currentUser?.uid
            )
        }

        @Test
        func loadingProfileWithoutAuthenticatedUserClearsFullName() async {
            guard Auth.auth().currentUser == nil else {
                return
            }

            let viewModel = AuthViewModel()
            viewModel.fullName = "Test User"

            await viewModel.loadUserProfile()

            #expect(viewModel.fullName == "")
        }

        @Test
        func logoutClearsProfileAndErrorMessagesWhenSignOutSucceeds() {
            let viewModel = AuthViewModel()

            viewModel.fullName = "Test User"
            viewModel.loginError = "Previous login error"
            viewModel.registerError = "Previous registration error"

            viewModel.logout()

            if Auth.auth().currentUser == nil {
                #expect(viewModel.user == nil)
                #expect(viewModel.fullName == "")
                #expect(viewModel.loginError == "")
                #expect(viewModel.registerError == "")
            }
        }
}
