//
//  AppLockView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-13.
//

import Foundation
import SwiftUI

struct AppLockView: View {

    @EnvironmentObject var appLock: AppLockManager

    @State private var authenticationFailed = false
    @State private var isAuthenticating = false

    var body: some View {
        ZStack {
            Color(
                red: 246.0 / 255.0,
                green: 242.0 / 255.0,
                blue: 235.0 / 255.0
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "faceid")
                    .font(.system(size: 54))

                Text("Unlock Memo")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Authenticate to access your memories.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Authenticate") {
                    Task {
                        await authenticate()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAuthenticating)
            }
            .padding(32)
        }
        .task {
            await authenticate()
        }
        .alert(
            "Unable to Unlock Memo",
            isPresented: $authenticationFailed
        ) {
            Button("Try Again") {
                Task {
                    await authenticate()
                }
            }
        } message: {
            Text(
                "Use Face ID or your iPhone passcode to continue. Your memories remain locked until authentication succeeds."
            )
        }
    }

    @MainActor
    private func authenticate() async {
        guard appLock.isLocked, !isAuthenticating else {
            return
        }

        isAuthenticating = true
        authenticationFailed = false

        await appLock.unlock()

        isAuthenticating = false

        if appLock.isLocked {
            authenticationFailed = true
        }
    }
}
