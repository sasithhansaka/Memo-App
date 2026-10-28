//
//  RegisterView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//

import SwiftUI

struct RegisterView: View {

    @EnvironmentObject var auth: AuthViewModel

    @State private var fullNameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showLoginView = false

    var body: some View {
        ZStack {
            MemoMapTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    VStack(spacing: 10) {
                        Image("logo-momento")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .accessibilityLabel("MemoMap logo")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Create your account")
                            .font(MemoFont.dmSansSemiBold(32))
                            .foregroundStyle(MemoMapTheme.black)

                        Text("Start collecting memories that matter.")
                            .font(MemoFont.dmSansRegular(14))
                            .foregroundStyle(MemoMapTheme.Textsecondary)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }
                    .padding(.top, 25)
                    .padding(.bottom, 30)

                    MemoMapTextField(
                        title: "Full name",
                        placeholder: "Your name",
                        text: $fullName,
                        error: fullNameError
                    )
                    .onChange(of: fullName) {
                        fullNameError = nil
                        auth.registerError = ""
                    }

                    MemoMapTextField(
                        title: "Email address",
                        placeholder: "you@example.com",
                        text: $email,
                        error: emailError
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.top, 18)
                    .onChange(of: email) {
                        emailError = nil
                        auth.registerError = ""
                    }

                    MemoMapSecureField(
                        title: "Password",
                        placeholder: "Create a password",
                        text: $password,
                        error: passwordError
                    )
                    .padding(.top, 18)
                    .onChange(of: password) {
                        passwordError = nil
                        auth.registerError = ""

                        if !confirmPassword.isEmpty {
                            confirmPasswordError = nil
                        }
                    }

                    MemoMapSecureField(
                        title: "Confirm password",
                        placeholder: "Repeat your password",
                        text: $confirmPassword,
                        error: confirmPasswordError
                    )
                    .padding(.top, 18)
                    .onChange(of: confirmPassword) {
                        confirmPasswordError = nil
                        auth.registerError = ""
                    }

                    if !auth.registerError.isEmpty {
                        Text(auth.registerError)
                            .font(MemoFont.dmSansRegular(12))
                            .foregroundStyle(.red)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                            .padding(.top, 12)
                    }

                    Button {
                        auth.registerError = ""

                        guard validateRegisterForm() else {
                            return
                        }

                        Task {
                            await auth.register(
                                fullName: fullName.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ),
                                email: email.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ),
                                password: password,
                                confirmPassword: confirmPassword
                            )
                        }

                    } label: {
                        HStack(spacing: 10) {
                            if auth.isLoading {
                                ProgressView()
                                    .tint(MemoMapTheme.White)
                            } else {
                                Text("Create Account")
                                    .font(MemoFont.dmSansBold(16))
                            }
                        }
                        .foregroundStyle(MemoMapTheme.White)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(MemoMapTheme.green)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(auth.isLoading)
                    .opacity(auth.isLoading ? 0.75 : 1)
                    .padding(.top, 30)

                    HStack(spacing: 5) {
                        Text("Already have an account?")
                            .font(MemoFont.dmSansRegular(13))
                            .foregroundStyle(
                                MemoMapTheme.Textsecondary.opacity(0.9)
                            )

                        Button {
                            showLoginView = true
                        } label: {
                            Text("Sign in")
                                .font(MemoFont.dmSansBold(13))
                                .foregroundStyle(MemoMapTheme.green)
                        }
                        .fullScreenCover(isPresented: $showLoginView) {
                            LoginView()
                                .environmentObject(auth)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 22)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 28)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.light)
    }

    private func validateRegisterForm() -> Bool {

        fullNameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil

        let cleanName = fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        var isValid = true

        // Validate full name

        if cleanName.isEmpty {
            fullNameError = "Please enter your full name."
            isValid = false
        }


        if cleanEmail.isEmpty {
            emailError = "Please enter your email address."
            isValid = false
        } else if !isValidEmail(cleanEmail) {
            emailError = "Please enter a valid email address."
            isValid = false
        }

        if password.isEmpty {
            passwordError = "Please enter a password."
            isValid = false
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters long."
            isValid = false
        }

        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password."
            isValid = false
        } else if password != confirmPassword {
            confirmPasswordError = "Passwords do not match."
            isValid = false
        }

        return isValid
    }

    private func isValidEmail(_ email: String) -> Bool {

        let emailRegex =
            #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        return email.range(
            of: emailRegex,
            options: .regularExpression
        ) != nil
    }
}

struct MemoMapTextField: View {

    let title: String
    let placeholder: String

    @Binding var text: String

    var error: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {

            Text(title)
                .font(MemoFont.dmSansBold(15))
                .foregroundStyle(MemoMapTheme.black)

            TextField(
                text: $text,
                prompt: Text(placeholder)
                    .foregroundColor(MemoMapTheme.Textsecondary.opacity(0.7))
            ) {
                Text(placeholder)
            }
            .font(MemoFont.dmSansRegular(15))
            .foregroundStyle(MemoMapTheme.black)
            .padding(.horizontal, 15)
            .frame(height: 52)
            .background(MemoMapTheme.inputBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        error == nil
                            ? MemoMapTheme.inputBorder
                        : Color.red.opacity(0.7),
                        lineWidth: 0.7
                    )
            }

            if let error, !error.isEmpty {
                Text(error)
                    .font(MemoFont.dmSansRegular(12))
                    .foregroundStyle(.red)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
    }
}

struct MemoMapSecureField: View {

    let title: String
    let placeholder: String

    @Binding var text: String

    var error: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {

            Text(title)
                .font(MemoFont.dmSansBold(15))
                .foregroundStyle(MemoMapTheme.black)

            SecureField(
                text: $text,
                prompt: Text(placeholder)
                    .foregroundColor(MemoMapTheme.Textsecondary.opacity(0.7))
            ) {
                Text(placeholder)
            }
            .font(MemoFont.dmSansRegular(15))
            .foregroundStyle(MemoMapTheme.black)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.newPassword)
            .padding(.horizontal, 15)
            .frame(height: 52)
            .background(MemoMapTheme.inputBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        error == nil
                            ? MemoMapTheme.inputBorder
                        : Color.red.opacity(0.7),
                        lineWidth: 0.7
                    )
            }

            if let error, !error.isEmpty {
                Text(error)
                    .font(MemoFont.dmSansRegular(12))
                    .foregroundStyle(.red)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
    }
}


#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
