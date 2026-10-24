//
//  OnboardingView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-24.
//

import Foundation
import SwiftUI
import UserNotifications
import CoreLocation

struct OnboardingView :  View {
    let onComplete : () -> Void
    
    @State private var currentPage = 0
    @State private var isRequestingPermission  = false
    @State private var permissionMassage : String?
    private let totalpages = 3
    
    var body: some View {
        
        ZStack {
            MemoMapTheme.background
                .ignoresSafeArea()
            
            VStack (spacing: 0) {
                
                HStack(spacing: 7) {
                    ForEach(0..<totalpages, id: \.self) { index in
                        Capsule()
                            .fill(
                                index <= currentPage
                                ? MemoMapTheme.green
                                : MemoMapTheme.inputBorder
                            )
                            .frame(height: 5)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)
                
                Spacer(minLength: 20)
                
                illustration
                    .frame(height: 240)
                    .padding(.top ,40)
                
                Spacer(minLength: 1)
                
                VStack(spacing: 8) {
                    Text(pageTitle)
                        .font(MemoFont.dmSansBold(28))
                        .foregroundStyle(MemoMapTheme.black)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(pageDescription)
                        .font(MemoFont.dmSansRegular(17))
                        .foregroundStyle(
                            MemoMapTheme.Textsecondary.opacity(0.8)
                        )
                        .padding(.top, 8)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                
                if let permissionMassage {
                    Text(permissionMassage)
                        .font(MemoFont.dmSansRegular(13))
                        .foregroundStyle(MemoMapTheme.Textsecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.top, 10)
                }

                Button {
                    handleContinue()
                } label: {
                    HStack(spacing: 10) {
                        if isRequestingPermission {
                            ProgressView()
                                .tint(MemoMapTheme.White)
                        } else {
                            Text(buttonTitle)
                                .font(MemoFont.dmSansBold(16))
                        }
                    }
                    .foregroundStyle(MemoMapTheme.White)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(MemoMapTheme.green)
                    .clipShape(Capsule())
                }
                .disabled(isRequestingPermission)
                .padding(.horizontal, 28)
                .padding(.top, 28)
                
                if currentPage == 1 || currentPage == 2 {
                    Button("Maybe later") {
                        moveToNextPage()
                    }
                    .font(MemoFont.dmSansMedium(14))
                    .foregroundStyle(MemoMapTheme.Textsecondary)
                    .padding(.top, 20)
                }
                
                Spacer(minLength: 12)
            }
        }
        
    }

    private var illustration: some View {
        Image(illustrationName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 340)
            .accessibilityHidden(true)
    }
            
    
    private var illustrationName: String {
                   switch currentPage {
                   case 0:
                       return "HomeImage"
                   case 1:
                       return "NotificationImage"
                   default:
                       return "LocationImage"
                   }
               }

               private var illustrationBadge: String {
                   switch currentPage {
                   case 0:
                       return "heart.fill"
                   case 1:
                       return "bell.fill"
                   default:
                       return "checkmark"
                   }
               }

            private var pageTitle: String {
                    switch currentPage {
                    case 0:
                        return "Every moment deserves a memory."
                    case 1:
                        return "Never miss a special moment."
                    default:
                        return "Let memories find you."
                    }
                }

                private var pageDescription: String {
                    switch currentPage {
                    case 0:
                        return """
                        Capture your favorite moments, save special places, \
                        and keep your stories close with MemoMap. Capture your favorite moments, \
                        save special places,
                        """

                    case 1:
                        return """
                        Receive notifications when you return to places \
                        connected to your saved memories.
                        """

                    default:
                        return """
                        Allow location access so MemoMap can recognize \
                        saved places and remind you about your memories, \
                        even when the app isn't open.
                        """
                    }
                }

            private var buttonTitle: String {
                    switch currentPage {
                    case 0:
                        return "Get Started"
                    case 1:
                        return "Enable Notifications"
                    default:
                        return "Enable Location"
                    }
                }

                private func handleContinue() {
                    permissionMassage = nil

                    switch currentPage {
                    case 0:
                        moveToNextPage()

                    case 1:
                        requestNotificationPermission()

                    case 2:
                        requestLocationPermission()

                    default:
                        onComplete()
                    }
                }

                private func moveToNextPage() {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if currentPage < totalpages - 1 {
                            currentPage += 1
                        } else {
                            onComplete()
                        }
                    }
                }

private func requestNotificationPermission() {
        isRequestingPermission = true

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in

                DispatchQueue.main.async {
                    isRequestingPermission = false

                    if let error {
                        permissionMassage =
                            "Notifications couldn't be enabled: "
                            + error.localizedDescription
                    } else if !granted {
                        permissionMassage =
                            "Notifications are disabled. You can enable "
                            + "them later in your iPhone Settings."
                    }

                    moveToNextPage()
                }
            }
    }

    private func requestLocationPermission() {
        isRequestingPermission = true

        LocationNotificationManager.shared
            .requestLocationPermission { message in

                isRequestingPermission = false

                if let message {
                    permissionMassage = message
                }

                moveToNextPage()
            }
    }

}
