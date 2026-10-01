//
//  Memo_app_IosApp.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//

import SwiftUI

@main
struct Memo_app_IosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    
    var appDelegate
    
    @StateObject private var auth = AuthViewModel()
    var body: some Scene {
        WindowGroup {
//            ContentView()
            RootView()
              .environmentObject(auth)
        }
    }
}
