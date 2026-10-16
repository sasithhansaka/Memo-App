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
            MemoMapTheme.background
            .ignoresSafeArea()
            
        
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading,spacing: 0) {
                    
                
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Account")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(MemoMapTheme.black)
                            
                            Text("Privacy, reminders and account.")
                                .font(.system(size: 12 , weight: .regular))
                                .foregroundStyle(MemoMapTheme.Textsecondary)
                        }
                        
                        Spacer(minLength: 8)
                        ZStack {
                            Image("LOGO")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: 100,
                                    height: 100
                                )
                        }
                        .frame(width: 76, height: 76)
                        
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 34)
                

                    VStack(spacing: 14) {
                        profileCard(
                             title: "Profile",
                             subtitle: auth.fullName.isEmpty
                                 ? "Loading profile..."
                                 : auth.fullName
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
                        
                        Button {
                                logout()
                            } label: {
                                HStack {
                                    Text("Log out")
                                        .font(
                                            .system(
                                                size: 14,
                                                weight: .semibold
                                            )
                                        )
                                        .foregroundStyle(MemoMapTheme.Textsecondary)

                                    Spacer()

                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 14))
                                        .foregroundStyle(MemoMapTheme.Textsecondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 54)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 19)
                                        .fill(MemoMapTheme.Textsecondary)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 19)
                                        .stroke(MemoMapTheme.inputBorder, lineWidth: 0.8)
                                }
                                .contentShape(
                                    RoundedRectangle(cornerRadius: 19)
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 110)
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
            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MemoMapTheme.Textsecondary
                    )

                if let subtitle = subtitle {
                    Text(
                        subtitle.isEmpty
                            ? "Not available"
                            : subtitle
                    )
                    .font(.system(size: 11 , weight: .regular))
                    .foregroundStyle(
                        MemoMapTheme.Textsecondary
                    )
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                }
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 19)
                .fill(
                    MemoMapTheme.background
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    MemoMapTheme.inputBorder ,lineWidth: 0.8
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 19))
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
