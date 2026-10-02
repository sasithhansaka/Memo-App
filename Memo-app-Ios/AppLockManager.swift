//
//  AppLockManager.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-02.
//

import Foundation
import LocalAuthentication

@MainActor
final class AppLockManager: ObservableObject {
   static let shared = AppLockManager ()
    
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
    
    
#Preview {
    AppLockManager()
}
