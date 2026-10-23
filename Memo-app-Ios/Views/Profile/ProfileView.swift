//
//
//  ProfileView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-02.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {

    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var appLock = AppLockManager.shared
    @State private var showFaceIDError = false
    @State private var faceIDErrorMessage = ""
    @State private var showLogoutConfirmation = false


    var body: some View {
        ZStack {
            MemoMapTheme.background
            .ignoresSafeArea()
            
        
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading,spacing: 0) {
                    
                    header
                    
                    VStack(spacing: 0) {
                        
                        sectionHeading("PERSONAL INFORMATIONS")

                        detailRow(
                            title: "Full name",
                            value: auth.fullName.isEmpty
                                ? "Loading profile..."
                                : auth.fullName
                        )

                        divider
                        
                        
                        detailRow(
                            title: "Email address",
                            value: auth.user?.email ?? "Not available"
                        )
                        
                        divider

                        Button {
                            Task {
                                if appLock.faceIDEnabled {
                                    let success = await appLock.disableFaceID()

                                    if !success {
                                        faceIDErrorMessage =
                                            "Face ID protection was not disabled. Please authenticate and try again."
                                        showFaceIDError = true
                                    }
                                } else {
                                    let success = await appLock.enableFaceID()

                                    if !success {
                                        faceIDErrorMessage =
                                            "Face ID could not be enabled. Check your device settings and try again."
                                        showFaceIDError = true
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Face ID")
                                        .font(MemoFont.dmSansMedium(16))
                                        .foregroundStyle(MemoMapTheme.black)

                                    Text(
                                        appLock.faceIDEnabled
                                            ? "Enabled"
                                            : "Disabled"
                                    )
                                    .font(MemoFont.dmSansRegular(14))
                                    .foregroundStyle(MemoMapTheme.Textsecondary)
                                }

                                Spacer()

                                Toggle(
                                    "Face ID",
                                    isOn: Binding(
                                        get: { appLock.faceIDEnabled },
                                        set: { _ in
                                            Task {
                                                if appLock.faceIDEnabled {
                                                    let success = await appLock.disableFaceID()
                                                    if !success {
                                                        faceIDErrorMessage =
                                                            "Face ID protection could not be disabled. Please authenticate and try again."
                                                        showFaceIDError = true
                                                    }
                                                } else {
                                                    let success = await appLock.enableFaceID()
                                                    if !success {
                                                        faceIDErrorMessage =
                                                            "Face ID could not be enabled. Check your device settings and try again."
                                                        showFaceIDError = true
                                                    }
                                                }
                                            }
                                        }
                                    )
                                )
                                .labelsHidden()
                                .tint(MemoMapTheme.green)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 20)

                        Button {
                            showLogoutConfirmation = true
                        } label: {
                            Text("Logout")
                                .font(MemoFont.dmSansMedium(17))
                                .foregroundStyle(MemoMapTheme.green)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background {
                                    Capsule()
                                        .fill(MemoMapTheme.background)
                                }
                                .overlay {
                                    Capsule()
                                        .stroke(
                                            MemoMapTheme.green.opacity(0.85),
                                            lineWidth: 1
                                        )
                                }
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 20)
                        .accessibilityHint("Double-tap to log out of your account")
                        }

                        Spacer(minLength: 30)
                    }
                .padding(.horizontal, 15)
                .padding(.top, 20)
                .padding(.bottom, 24)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
                }
            }
        .task {
            await auth.loadUserProfile()
        }
        .alert(
            "Face ID",
            isPresented: $showFaceIDError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(faceIDErrorMessage)
        }
        .alert(
            "Log Out?",
            isPresented: $showLogoutConfirmation
        ) {
            Button("Cancel", role: .cancel) {
            }

            Button("Log Out", role: .destructive) {
                appLock.resetForLogout()
                auth.logout()
            }
        } message: {
            Text("Are you sure you want to log out of your account?")
        }
    }
    
    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Account")
                    .font(MemoFont.dmSansRegular(34))
                    .foregroundStyle(MemoMapTheme.black)

                Text("Your memories are waiting to be rediscovered.")
                    .font(MemoFont.dmSansRegular(15))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom ,24)
    }
    
    
    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(MemoFont.dmSansMedium(12))
            .foregroundStyle(MemoMapTheme.Textsecondary)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func detailRow(
    title: String,
    value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(MemoFont.dmSansMedium(16))
                .foregroundStyle(MemoMapTheme.black)

            Text(value)
                .font(MemoFont.dmSansRegular(15))
                .foregroundStyle(MemoMapTheme.Textsecondary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(MemoMapTheme.inputBorder.opacity(0.5))
            .frame(height: 1)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
