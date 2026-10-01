//
//  RegisterView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var auth : AuthViewModel
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    
    var body: some View {
        
        ZStack {
            
            MemoMapTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 0) {
                                        
                    VStack(spacing: 0) {
                        
                        Image("MemoMapLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 100,
                                height: 100
                            )
                        
                        Text("MEMOMAP")
                            .font(
                                .system(
                                    size: 8,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(
                                MemoMapTheme.green
                            )
                            .padding(.top, -1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 47)
                    
                                        
                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {
                        
                        Text("Create your account")
                            .font(
                                .system(
                                    size: 22,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                MemoMapTheme.black
                            )
                        
                        Text(
                            "Start collecting memories that matter."
                        )
                        .font(.system(size: 10))
                        .foregroundStyle(
                            MemoMapTheme.Textsecondary
                        )
                    }
                    .padding(.top, 12)
                    
                                        
                    MemoMapTextField(
                        title: "Full name",
                        placeholder: "Your name",
                        text: $fullName
                    )
                    .padding(.top, 24)
                    
                                        
                    MemoMapTextField(
                        title: "Email",
                        placeholder: "you@example.com",
                        text: $email
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.top, 16)
                    
                                    
                    MemoMapSecureField(
                        title: "Password",
                        placeholder: "Create a password",
                        text: $password
                    )
                    .padding(.top, 16)
                    
                                    
                    MemoMapSecureField(
                        title: "Confirm password",
                        placeholder: "Repeat your password",
                        text: $confirmPassword
                    )
                    .padding(.top, 16)
                
                    if !auth.errormessage.isEmpty {
                        
                        Text(auth.errormessage)
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                            .padding(.top, 12)
                    }
                    
                    Button {
                        
                        Task {
                            
                            await auth.register(
                                fullName: fullName,
                                email: email,
                                password: password,
                                confirmPassword: confirmPassword
                            )
                        }
                        
                    } label: {
                        
                        Group {
                            if auth.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create account")
                            }
                        }
                        .font(
                            .system(
                                size: 11,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 37)
                        .background(
                            MemoMapTheme.green
                        )
                        .clipShape(Capsule())
                    }
                    .disabled(auth.isLoading)
                    .padding(.top, 20)
                    
                    HStack(spacing: 4) {
                        
                        Text("Already have an account?")
                        
                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("Sign in")
                                .foregroundStyle(
                                    MemoMapTheme.green
                                )
                        }
                    }
                    .font(
                        .system(
                            size: 9,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        MemoMapTheme.Textsecondary
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 29)
            }
        }
        .preferredColorScheme(.light)
    }
}



struct MemoMapTextField: View {
    
let title: String
let placeholder: String
@Binding var text: String

var body: some View {
    
    VStack(
        alignment: .leading,
        spacing: 6
    ) {
        
        Text(title)
            .font(
                .system(
                    size: 9,
                    weight: .medium
                )
            )
            .foregroundStyle(
                MemoMapTheme.Textsecondary
            )
        
        TextField(
            placeholder,
            text: $text
        )
        .font(.system(size: 10))
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(
            MemoMapTheme.inputBackground
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 10
            )
            .stroke(
                MemoMapTheme.inputBorder,
                lineWidth: 0.8
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 10
            )
        )
    }
}
}

struct MemoMapSecureField: View {
    
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        
        VStack(
            alignment: .leading,
            spacing: 6
        ) {
            
            Text(title)
                .font(
                    .system(
                        size: 9,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    MemoMapTheme.Textsecondary
                )
            
            SecureField(
                placeholder,
                text: $text
            )
            .font(.system(size: 10))
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(
                MemoMapTheme.inputBackground
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 10
                )
                .stroke(
                    MemoMapTheme.inputBorder,
                    lineWidth: 0.8
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 10
                )
            )
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
