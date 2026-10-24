//
//  RootView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//

import SwiftUI
import Foundation
import FirebaseAuth


struct RootView: View {

    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var appLock: AppLockManager
    
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    var body: some View {
        Group {
               if !hasCompletedOnboarding {
                   OnboardingView {
                       hasCompletedOnboarding = true
                   }

               } else if auth.user == nil {
                   LoginView()

               } else if appLock.isLocked {
                   AppLockView()

               } else {
                   MainTabView()
               }
           }
            .task(id: auth.user?.uid) {
                guard auth.user != nil, !appLock.isLocked else {
                    return
                }

                LocationNotificationManager.shared.start()
                LocationNotificationManager.shared.refresh()
            }
    }

    
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppLockManager.shared)
}
