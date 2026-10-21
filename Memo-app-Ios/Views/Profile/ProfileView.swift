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
                    
                    header
                    
                    VStack(spacing: 0) {
                        
                        sectionHeading("PERSONAL DETAILS")

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
                        
                        divider

                      // OTHER
                      sectionHeading("OTHER")
                          .padding(.top, 24)
                        
                        Button {
                            
                            appLock.resetForLogout()
                            auth.logout()
                            
                        } label: {
                            HStack {
                                Text("Log out")
                                   .font(MemoFont.dmSansMedium(16))
                                   .foregroundStyle(MemoMapTheme.black)

                               Spacer()

                                Spacer()

                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16))
                                .foregroundStyle(MemoMapTheme.Textsecondary)
                                }
                            .padding(.vertical, 20)
                            .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
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
    }
    
    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Account")
                    .font(MemoFont.dmSansRegular(34))                    .foregroundStyle(MemoMapTheme.black)

                Text("Your memories are waiting to be rediscovered.")
                    .font(MemoFont.dmSansRegular(15))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 2)

//            Image("LOGO")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 76, height: 76)
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

//    private func logout() {
//        appLock.resetForLogout()
//
//        auth.logout()
//    }
    
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
