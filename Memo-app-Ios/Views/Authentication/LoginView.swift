import SwiftUI

struct LoginView: View {

    @EnvironmentObject var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {

        NavigationStack {
            ZStack {

                MemoMapTheme.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {

                    VStack(alignment: .leading, spacing: 0) {
                        
                        VStack(spacing: 0) {

                            Image("LOGO")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: 150,
                                    height: 150
                                )
                            
//                            Text("MEMOMAP")
//                                .font(.system(size: 11, weight: .semibold))
//                                .foregroundStyle(MemoMapTheme.green)
//                                .padding(.top, -2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 90)

                        VStack(alignment: .leading, spacing: 5) {

                            Text("Welcome back")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(MemoMapTheme.black)

                            Text("Unlock your memories.")
                                .font(.system(size: 14))
                                .foregroundStyle(MemoMapTheme.Textsecondary)
                        }
                        .padding(.top, 12)

                        VStack(alignment: .leading, spacing: 8) {

                            Text("Email")
                                .font(
                                    .system(
                                        size:12,
                                        weight: .medium
                                    )
                                )
                                .foregroundStyle(
                                    MemoMapTheme.Textsecondary
                                )

                            TextField("you@example.com", text: $email)
                                .font(.system(size: 13))
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .padding(.horizontal, 14)
                                .frame(height: 42)
                                .background(MemoMapTheme.inputBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 13)
                                        .stroke(
                                            MemoMapTheme.inputBorder,
                                            lineWidth: 1
                                        )
                                }
                        }
                        .padding(.top, 24)

                        VStack(alignment: .leading, spacing: 8) {

                            Text("Password")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(MemoMapTheme.Textsecondary)

                            SecureField("••••••••••", text: $password)
                                .font(.system(size: 13))
                                .textContentType(.password)
                                .padding(.horizontal, 14)
                                .frame(height: 42)
                                .background(MemoMapTheme.inputBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 13)
                                        .stroke(
                                            MemoMapTheme.inputBorder,
                                            lineWidth: 1
                                        )
                                }
                        }
                        .padding(.top, 22)

                        if !auth.errormessage.isEmpty {
                            Text(auth.errormessage)
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                                .padding(.top, 12)
                        }

                        Button {
                            Task {
                                await auth.login(
                                    email: email,
                                    password: password
                                )
                            }
                        } label: {

                            Group {
                                if auth.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                }
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(MemoMapTheme.green)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .disabled(auth.isLoading)
                        .padding(.top, 39)

                        HStack(spacing: 4) {
                            
                            Text("New here?")
                            
                            NavigationLink {
                                RegisterView()
                            } label: {
                            Text("Create account")
                                .foregroundStyle(MemoMapTheme.green)
                            }
                        }

//                        HStack(spacing: 5) {
//
//                            Text("New here?")
//                                .foregroundStyle(MemoMapTheme.green)
//
//                            NavigationLink {
//                                RegisterView()
//                            } label: {
//                                Text("Create account")
//                                    .foregroundStyle(MemoMapTheme.green)
//                            }
//                        }
                        .font(
                            .system(
                                size: 11,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            MemoMapTheme.Textsecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                        .padding(.bottom, 35)
                    }
                    .padding(.horizontal, 29)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
