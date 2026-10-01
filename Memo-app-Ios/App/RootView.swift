//
//  RootView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//


import SwiftUI


struct RootView: View {
    
    @EnvironmentObject var  auth : AuthViewModel
    
    
    var body: some View {
        Group{
            if auth.user != nil {
                HomeView()
            }
            else{
                LoginView()
            }
        }
        
        
    }
}

#Preview{
    RootView()
        .environmentObject(AuthViewModel())
}
