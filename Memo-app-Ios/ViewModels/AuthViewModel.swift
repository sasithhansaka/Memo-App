//
//  AuthViewModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var user: FirebaseAuth.User?
    @Published var fullName = ""
    @Published var isLoading = false
    @Published var loginError = ""
    @Published var registerError = ""

    private let db = Firestore.firestore()
    private var authListenerHandle: AuthStateDidChangeListenerHandle?


    init() {
            user = Auth.auth().currentUser

            authListenerHandle = Auth.auth().addStateDidChangeListener {
                [weak self] _, user in

                Task { @MainActor [weak self] in
                    guard let self else { return }

                    self.user = user

                    if user != nil {
                        await self.loadUserProfile()
                    } else {
                        self.fullName = ""
                    }
                }
            }
        }
    
    deinit {
        if let authListenerHandle {
            Auth.auth().removeStateDidChangeListener(authListenerHandle)
        }
    }



    func register(
        fullName: String,
        email: String,
        password: String,
        confirmPassword: String
    ) async {

        registerError = ""

        let cleanName = fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty else {
            registerError = "Please enter your full name."
            return
        }

        guard !cleanEmail.isEmpty else {
            registerError = "Please enter your email address."
            return
        }

        guard checkIsValidEmail(cleanEmail) else {
            registerError = "Please enter a valid email address."
            return
        }

        guard !password.isEmpty else {
            registerError = "Please enter a password."
            return
        }

        guard password.count >= 8 else {
            registerError = "Password must be at least 8 characters long."
            return
        }

        guard !confirmPassword.isEmpty else {
            registerError = "Please confirm your password."
            return
        }

        guard password == confirmPassword else {
            registerError = "Passwords do not match."
            return
        }

        isLoading = true

        do {
            let result = try await Auth.auth().createUser(
                withEmail: cleanEmail,
                password: password
            )

            let uid = result.user.uid

            let userData: [String: Any] = [
                "uid": uid,
                "fullName": cleanName,
                "email": cleanEmail,
                "createdAt": FieldValue.serverTimestamp()
            ]

            try await db
                .collection("users")
                .document(uid)
                .setData(userData)

            user = result.user
            isLoading = false

        } catch {
            registerError = firebaseErrorMessage(error)
            isLoading = false
        }
    }

    func login(
        email: String,
        password: String
    ) async {

        loginError = ""

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanEmail.isEmpty else {
            loginError = "Please enter your email address."
            return
        }

        guard checkIsValidEmail(cleanEmail) else {
            loginError = "Please enter a valid email address."
            return
        }

        guard !password.isEmpty else {
            loginError = "Please enter your password."
            return
        }

        isLoading = true

        do {
            let result = try await Auth.auth().signIn(
                withEmail: cleanEmail,
                password: password
            )

            user = result.user
            isLoading = false

        } catch {
            loginError = firebaseErrorMessage(error)
            isLoading = false
        }
    }
    
    func loadUserProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            fullName=""
            return
        }


        do {

            let document = try await db
                .collection("users")
                .document(uid)
                .getDocument()


            guard let data = document.data() else {
                fullName=""
                return
            }


            fullName = data["fullName"] as? String ?? ""

        } catch {
            print(
                "Failed to load user profile:",
                error.localizedDescription
        )
        }
    }

    func logout() {

        do {
            try Auth.auth().signOut()
            user = nil
            fullName=""
            loginError = ""
            registerError = ""

        } catch {
            loginError = error.localizedDescription
        }
    }

    private func checkIsValidEmail(_ email: String) -> Bool {

        let emailRegex =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        return email.range(
            of: emailRegex,
            options: .regularExpression
        ) != nil
    }

    private func firebaseErrorMessage(_ error: Error) -> String {

        let nsError = error as NSError

        guard let code = AuthErrorCode(
            rawValue: nsError.code
        ) else {
            return "Something went wrong. Please try again."
        }

        switch code {

        case .emailAlreadyInUse:
            return "An account already exists with this email."

        case .invalidEmail:
            return "Please enter a valid email address."

        case .weakPassword:
            return "Please enter a stronger password."

        case .wrongPassword:
            return "Incorrect email or password."

        case .userNotFound:
            return "Incorrect email or password."

        case .invalidCredential:
            return "Incorrect email or password."

        case .userDisabled:
            return "This account has been disabled."

        case .networkError:
            return "Check your internet connection and try again."

        case .tooManyRequests:
            return "Too many attempts. Please try again later."

        default:
            return "Something went wrong. Please try again."
        }
    }
}
