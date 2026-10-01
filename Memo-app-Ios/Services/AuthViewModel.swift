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
    @Published var isLoading = false
    @Published var errormessage = ""


    private let db = Firestore.firestore()


    init() {
        self.user = Auth.auth().currentUser

        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }


    func register(
        fullName: String,
        email: String,
        password: String,
        confirmPassword: String
    ) async {

        errormessage = ""

        let cleanName = fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty else {
            errormessage = "Please enter your full name."
            return
        }
        
        guard !cleanEmail.isEmpty else {
            errormessage = "Please enter a email."
            return
        }

        guard !password.isEmpty else {
            errormessage = "Please enter a password."
            return
        }

        guard password.count >= 6 else {
            errormessage = "Password must be at least 6 characters long."
            return
        }

        guard password == confirmPassword else {
            errormessage = "Passwords do not match."
            return
        }

        guard checkIsValidEmail(cleanEmail) else {
            errormessage = "Please enter a valid email address."
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

            errormessage = firebaseErrorMessage(error)
            isLoading = false
        }
    }

    func login(
        email: String,
        password: String
    ) async {

        errormessage = ""

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanEmail.isEmpty else {
            errormessage = "Please enter your email address."
            return
        }

        guard !password.isEmpty else {
            errormessage = "Please enter your password."
            return
        }

        guard checkIsValidEmail(cleanEmail) else {
            errormessage = "Please enter a valid email address."
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

            isLoading = false
            errormessage = firebaseErrorMessage(error)
        }
    }

    func logout() {

        do {

            try Auth.auth().signOut()

            user = nil

        } catch {

            errormessage = error.localizedDescription
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
