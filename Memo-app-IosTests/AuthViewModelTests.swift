//
//  AuthViewModelTests.swift
//  Memo-app-IosTests
//
//  Created by student3 on 2026-10-28.
//
import Testing
@testable import Memo_app_Ios

@MainActor
struct AuthViewModelTests {

    @Test
        func registerWithEmptyNameShowsError() async {
            let viewModel = AuthViewModel()

            await viewModel.register(
                fullName: "",
                email: "test@example.com",
                password: "Password123",
                confirmPassword: "Password123"
            )

            #expect(
                viewModel.registerError == "Please enter your full name."
            )
        }

        @Test
        func registerWithEmptyEmailShowsError() async {
            let viewModel = AuthViewModel()

            await viewModel.register(
                fullName: "Test User",
                email: "",
                password: "Password123",
                confirmPassword: "Password123"
            )

            #expect(
                viewModel.registerError == "Please enter your email address."
            )
        }

        @Test
        func registerWithInvalidEmailShowsError() async {
            let viewModel = AuthViewModel()

            await viewModel.register(
                fullName: "Test User",
                email: "invalid-email",
                password: "Password123",
                confirmPassword: "Password123"
            )

            #expect(
                viewModel.registerError == "Please enter a valid email address."
            )
        }

        @Test
        func registerWithEmptyPasswordShowsError() async {
            let viewModel = AuthViewModel()

            await viewModel.register(
                fullName: "Test User",
                email: "test@example.com",
                password: "",
                confirmPassword: ""
            )

            #expect(
                viewModel.registerError == "Please enter a password."
            )
        }

        @Test
        func registerWithShortPasswordShowsError() async {
            let viewModel = AuthViewModel()

            await viewModel.register(
                fullName: "Test User",
                email: "test@example.com",
                password: "abc123",
                confirmPassword: "abc123"
            )

            #expect(
                viewModel.registerError == "Password must be at least 8 characters long."
            )
        }

        @Test
        func registerWithEmptyConfirmationShowsError() async {
            let viewModel = AuthViewModel()

            await viewModel.register(
                fullName: "Test User",
                email: "test@example.com",
                password: "Password123",
                confirmPassword: ""
            )

            #expect(
                viewModel.registerError == "Please confirm your password."
            )
        }


        @Test
        func registerWithMismatchedPasswordsShowsError() async {
            let viewModel = AuthViewModel()

            await viewModel.register(
                fullName: "Test User",
                email: "test@example.com",
                password: "Password123",
                confirmPassword: "Different123"
            )

            #expect(
                viewModel.registerError == "Passwords do not match."
            )
        }
    
    @Test
       func loginWithEmptyPasswordShowsError() async {
           let viewModel = AuthViewModel()

           await viewModel.login(
               email: "test@example.com",
               password: ""
           )

           #expect(viewModel.loginError == "Please enter your password.")
       }

       @Test
       func loginWithEmptyEmailAndPasswordShowsEmailError() async {
           let viewModel = AuthViewModel()

           await viewModel.login(
               email: "",
               password: ""
           )

           #expect(viewModel.loginError == "Please enter your email address.")
       }

       @Test
       func loginClearsPreviousErrorBeforeValidation() async {
           let viewModel = AuthViewModel()

           viewModel.loginError = "Previous error"

           await viewModel.login(
               email: "",
               password: "Password123"
           )

           #expect(viewModel.loginError == "Please enter your email address.")
           #expect(viewModel.isLoading == false)
       }
}
