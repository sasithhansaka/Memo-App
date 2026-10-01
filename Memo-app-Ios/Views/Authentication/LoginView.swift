//
//  LoginView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//



import SwiftUI

struct LoginView : View {
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var  errorMessage="";
    
    var body: some View {
        
        NavigationStack {
            
            ZStack{
                
                MemoMapTheme.background
                    .ignoresSafeArea()
                
                // scrollview(
                
                // )
                
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
                    .padding(.top, 55)
                    
                    VStack(alignment: .leading, spacing:0){
                        Text("Welcome back")
                            .font(
                                .system(
                                    size: 23,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                MemoMapTheme.Textsecondary
                            )
                        
                        Text("Unlock your memories.")
                            .font(
                                .system(size: 10)
                            )
                            .foregroundStyle(
                                MemoMapTheme.Textsecondary
                            )
                    }
                    .padding(.top, 27)
                    
                    VStack (alignment: .leading, spacing:6){
                        
                        Text("Email")
                            .font(
                                .system (
                                    size:9,
                                    weight: .medium
                                )
                            )
                        
                            .foregroundStyle(
                                MemoMapTheme.Textsecondary
                            )
                        
                        TextField (
                            "you@Example.com",
                            text: $email
                        )
                        
                        .font(.system(size:10))
                        
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 12)
                        .frame(height: 38)
                        .background ( MemoMapTheme.inputBackground)
                        
                        
                    }
                    
                    .padding (.top , 39)
                    
                    VStack (alignment: .leading, spacing:6){
                        
                        Text("password")
                            .font(
                                .system(
                                    size: 9,
                                    //                                weight: medium
                                )
                            )
                        
                            .foregroundStyle(
                                MemoMapTheme.Textsecondary
                            )
                        
                            SecureField (
                            "......",
                            text: $password
                            )
                            .font(.system(size: 10))
                            .padding(.horizontal, 12)
                            .frame(height: 38)
                            .background(
                            MemoMapTheme.inputBackground)
                         .overlay(
                             RoundedRectangle(
                                 cornerRadius: 10
                             )
                             .stroke(
                                 MemoMapTheme.inputBorder,
                                 lineWidth: 0.8
                             )
                         )
//                         .clipShape()
                        
                        
                    }
                    
                    
                    if !auth.errormessage.isEmpty{
                        
                        Text(auth.errormessage)
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                            .padding(.top, 12)
                    }
                    
                    Button{
                        Task{
                            await auth.login(
                                email: email,
                                password: password
                            )
                        }
                        } label: {
                            Group{
                                if auth.isLoading{
                                    ProgressView ()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                }
                            }
                            .font(
                                .system(
                                    size: 11,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(.white)
                            .frame(
                                maxWidth: .infinity
                            )
                            .frame(height: 37)
//                            .background(
//                                MemoMapTheme.primaryGreen
//                            )
                            .clipShape(Capsule())
                        }
                        
                        .disabled(auth.isLoading)
                        .padding(.top, 28)
                        
                        HStack(spacing: 4){
                            
                            NavigationLink {
                                RegisterView()
                            } label : {
                                Text("Dont have a account ? ")
                            }
                            
                        }
                        
                    }
                    
                }
        }
    }
}


