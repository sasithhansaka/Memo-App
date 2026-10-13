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

    var body: some View {
        ZStack {
            Color(
                red: 246.0 / 255.0,
                green: 242.0 / 255.0,
                blue: 235.0 / 255.0
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                VStack(alignment: .leading, spacing: 4) {
                    Text("Account")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(Color(
                            red: 30.0 / 255.0,
                            green: 35.0 / 255.0,
                            blue: 33.0 / 255.0
                        ))

                    Text("Privacy, reminders and account.")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 36)
                .padding(.top, 40)
                .padding(.bottom, 28)

  
                ScrollView {
                    VStack(spacing: 16) {


                        profileCard(
                            title: "Profile",
                            subtitle: auth.fullName.isEmpty
                                ? "Loading profile..."
                                : auth.fullName
                        )


                        profileCard(
                            title: "Email",
                            subtitle: auth.user?.email ?? "No email available"
                        )

                        Button {
                            Task {
                                await toggleFaceID()
                            }
                        } label: {
                            profileCardContent(
                                title: "Face ID",
                                subtitle: appLock.faceIDEnabled
                                    ? "Enabled"
                                    : "Disabled",
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint(
                            "Double tap to change Face ID protection."
                        )

                        // Logout

                        Button {
                            logout()
                        } label: {
                            profileCardContent(
                                title: "Log out",
                                subtitle: nil,
                                showsChevron: false
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 36)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
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
    }

    @MainActor
    private func toggleFaceID() async {

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
                    "Face ID could not be enabled. Check that Face ID or a device passcode is configured in your iPhone settings, then try again."
                showFaceIDError = true
            }
        }
    }

    private func profileCard(
        title: String,
        subtitle: String
    ) -> some View {
        profileCardContent(
            title: title,
            subtitle: subtitle,
            showsChevron: false
        )
    }

    private func profileCardContent(
        title: String,
        subtitle: String?,
        showsChevron: Bool
    ) -> some View {

        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        Color(
                            red: 30.0 / 255.0,
                            green: 35.0 / 255.0,
                            blue: 33.0 / 255.0
                        )
                    )

                if let subtitle = subtitle {
                    Text(
                        subtitle.isEmpty
                            ? "Not available"
                            : subtitle
                    )
                    .font(.system(size: 16))
                    .foregroundStyle(
                        Color(
                            red: 102.0 / 255.0,
                            green: 107.0 / 255.0,
                            blue: 99.0 / 255.0
                        )
                    )
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                }
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    Color(
                        red: 253.0 / 255.0,
                        green: 251.0 / 255.0,
                        blue: 246.0 / 255.0
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    Color(
                        red: 220.0 / 255.0,
                        green: 213.0 / 255.0,
                        blue: 200.0 / 255.0
                    ),
                    lineWidth: 1
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 28))
    }

    private func logout() {
        appLock.resetForLogout()

        auth.logout()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
