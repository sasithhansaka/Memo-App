//
//  LoginView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var auth: AuthViewModel

    @State private var showRegisterView = false
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var emailError: String?
    @State private var passwordError: String?

    var body: some View {

        NavigationStack {

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
                        .padding(.top, 95)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome back")
                                .font(MemoFont.dmSansSemiBold(32))
                                .foregroundStyle(MemoMapTheme.black)

                            Text("Sign in to revisit your memories.")
                                .font(MemoFont.dmSansRegular(14))
                                .foregroundStyle(MemoMapTheme.Textsecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 30)
                    
                        VStack(alignment: .leading, spacing: 11) {

                            Text("Email address")
                                .font(MemoFont.dmSansBold(15))
                                .foregroundStyle(MemoMapTheme.black)

                            HStack(spacing: 11) {
                                Image(systemName: "envelope")
                                    .font(.system(size: 16))
                                    .foregroundStyle(MemoMapTheme.green)
                                    .frame(width: 20)

                                TextField(
                                    text: $email,
                                    prompt: Text("you@example.com")
                                        .foregroundColor(MemoMapTheme.Textsecondary)
                                ) {
                                    Text("you@example.com")
                                }
                                .font(MemoFont.dmSansRegular(15))
                                .foregroundStyle(MemoMapTheme.black)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                // .textContentType(.emailAddress)
                                .submitLabel(.next)
                                .onChange(of: email) {
                                    emailError = nil
                                    auth.loginError = ""
                                }
                            }
                            .padding(.horizontal, 15)
                            .frame(height: 52)
                            .background(MemoMapTheme.inputBackground)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        emailError == nil
                                            ? MemoMapTheme.inputBorder
                                        : Color.red.opacity(0.7),
                                        lineWidth: 0.7
                                    )
                            }

                            if let emailError {

                                Text(emailError)
                                    .font(MemoFont.dmSansRegular(12))
                                    .foregroundStyle(.red)
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                            }
                        }

                        VStack(alignment: .leading, spacing: 9) {

                            Text("Password")
                                .font(MemoFont.dmSansBold(15))
                                .foregroundStyle(MemoMapTheme.black)

                            HStack(spacing: 11) {

                                Image(systemName: "lock")
                                    .font(.system(size: 16))
                                    .foregroundStyle(MemoMapTheme.green)
                                    .frame(width: 20)

                                Group {

                                    if isPasswordVisible {

                                    TextField(
                                       text: $password,
                                       prompt: Text("Enter your password")
                                        .foregroundColor(MemoMapTheme.Textsecondary.opacity(0.7))
                                   ) {
                                       Text("Enter your password")
                                   }

                                    } else {

                                    SecureField(
                                        text: $password,
                                        prompt: Text("Enter your password")
                                            .foregroundColor(MemoMapTheme.Textsecondary.opacity(0.7))
                                    ) {
                                        Text("Enter your password")
                                    }
                                    }
                                }
                                .font(MemoFont.dmSansRegular(15))
                                .foregroundStyle(MemoMapTheme.black)
                                .textContentType(.password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .submitLabel(.go)
                                .onSubmit {
                                    signIn()
                                }
                                .onChange(of: password) {
                                    passwordError = nil
                                    auth.loginError = ""
                                }

                                Button {

                                    isPasswordVisible.toggle()

                                } label: {

                                    Image(
                                        systemName: isPasswordVisible
                                            ? "eye.slash"
                                            : "eye"
                                    )
                                    .font(.system(size: 15))
                                    .foregroundStyle(
                                        MemoMapTheme.Textsecondary
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(
                                    isPasswordVisible
                                        ? "Hide password"
                                        : "Show password"
                                )
                            }
                            .padding(.horizontal, 15)
                            .frame(height: 52)
                            .background(MemoMapTheme.inputBackground)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        passwordError == nil
                                            ? MemoMapTheme.inputBorder
                                        : Color.red.opacity(0.7),
                                        lineWidth: 0.7
                                    )
                            }

                            // Password validation message

                            if let passwordError {

                                Text(passwordError)
                                    .font(MemoFont.dmSansRegular(12))
                                    .foregroundStyle(.red)
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                            }
                        }
                        .padding(.top, 20)

                        if !auth.loginError.isEmpty {

                            Text(auth.loginError)
                                .font(MemoFont.dmSansRegular(12))
                                .foregroundStyle(.red)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                                .padding(.top, 12)
                        }

                        Button {

                            signIn()

                        } label: {

                            HStack(spacing: 10) {

                                if auth.isLoading {

                                    ProgressView()
                                        .tint(MemoMapTheme.White)

                                } else {

                                    Text("Sign In")
                                        .font(
                                            MemoFont.dmSansBold(16)
                                        )
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
                        .padding(.top, 40)

                        HStack(spacing: 5) {

                            Text("New to here?")
                                .foregroundStyle(
                                    MemoMapTheme.Textsecondary.opacity(0.9)
                                )
                                .font(MemoFont.dmSansRegular(13))

                            Button {

                                showRegisterView = true

                            } label: {

                                Text("Create account")
                                    .font(
                                        MemoFont.dmSansBold(13)
                                    )
                                    .foregroundStyle(
                                        MemoMapTheme.green
                                    )
                            }
                            .fullScreenCover(
                                isPresented: $showRegisterView
                            ) {
                                RegisterView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 28)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func validateLoginForm() -> Bool {

        // Clear previous validation errors
        emailError = nil
        passwordError = nil

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        var isValid = true


        if cleanEmail.isEmpty {

            emailError = "Please enter your email address."
            isValid = false

        } else if !isValidEmail(cleanEmail) {

            emailError = "Please enter a valid email address."
            isValid = false
        }

        if password.isEmpty {

            passwordError = "Please enter your password."
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

    private func signIn() {

        guard !auth.isLoading else {
            return
        }
        guard validateLoginForm() else {
            return
        }
        auth.loginError = ""

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        Task {

            await auth.login(
                email: cleanEmail,
                password: password
            )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
