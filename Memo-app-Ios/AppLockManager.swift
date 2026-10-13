//
//  AppLockManager.swift
//  Memo-app-Ios
//

import Foundation
import LocalAuthentication
import Combine

@MainActor
final class AppLockManager: ObservableObject {

    static let shared = AppLockManager()


 
    @Published private(set) var isLocked = false

    private let faceIDEnabledKey = "faceIDEnabled"
    private let backgroundDateKey = "appBackgroundDate"

    private init() {

        if UserDefaults.standard.bool(
            forKey: faceIDEnabledKey
        ) {

            isLocked = true
        }
    }
    
    var faceIDEnabled: Bool {

        UserDefaults.standard.bool(
            forKey: faceIDEnabledKey
        )
    }
    
    func enableFaceID() async -> Bool {

        let context = LAContext()

        var error: NSError?

        guard context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        ) else {

            return false
        }


        do {

            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason:
                    "Enable Face ID to protect your private memories."
            )


            if success {

                UserDefaults.standard.set(
                    true,
                    forKey: faceIDEnabledKey
                )

                isLocked = false
                return true
            }
            
            return false

        } catch {

            print(
                "Face ID enable failed:",
                error.localizedDescription
            )

            return false
        }
    }

    func disableFaceID() async -> Bool {

        let context = LAContext()

        var error: NSError?


        guard context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        ) else {

            return false
        }


        do {

            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason:
                    "Confirm your identity to disable Face ID protection."
            )


            if success {

                UserDefaults.standard.set(
                    false,
                    forKey: faceIDEnabledKey
                )

                isLocked = false

                return true
            }


            return false

        } catch {

            print(
                "Face ID disable failed:",
                error.localizedDescription
            )

            return false
        }
    }

    func lock() {

        guard faceIDEnabled else {
            return
        }

        isLocked = true
    }

    func unlock() async {

        guard faceIDEnabled else {

            isLocked = false
            return
        }


        let context = LAContext()

        var error: NSError?


        guard context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        ) else {

            return
        }


        do {

            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason:
                    "Unlock Memo to access your private memories."
            )


            if success {

                isLocked = false
            }

        } catch {

            isLocked = true

            print(
                "Unlock failed:",
                error.localizedDescription
            )
        }
    }

    func applicationDidEnterBackground() {

        guard faceIDEnabled else {
            return
        }


        UserDefaults.standard.set(
            Date(),
            forKey: backgroundDateKey
        )
    }

    func applicationBecameActive() {

        guard faceIDEnabled else {
            return
        }

        guard let backgroundDate = UserDefaults.standard.object(
            forKey: backgroundDateKey
        ) as? Date else {
            return
        }

        // Consume the timestamp so it cannot lock the app repeatedly.
        UserDefaults.standard.removeObject(forKey: backgroundDateKey)

        let elapsed = Date().timeIntervalSince(backgroundDate)

        if elapsed >= 30 {
            isLocked = true
        }
    }
    
    func resetForLogout() {

        UserDefaults.standard.removeObject(
            forKey: faceIDEnabledKey
        )

        UserDefaults.standard.removeObject(
            forKey: backgroundDateKey
        )

        isLocked = false
    }
}
