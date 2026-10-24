import SwiftUI

struct LoginView: View {

    @EnvironmentObject var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {

        NavigationStack {
            ZStack {

                MemoMapTheme.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {

                    VStack(alignment: .leading, spacing: 0) {
                        
                        VStack(spacing: 10) {

                            Image("LOGO")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150,height: 150)
                                .accessibilityLabel("MemoMap logo")
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 65)

                        VStack(alignment: .leading, spacing: 8) {

                            Text("Welcome back")
                                .font(MemoFont.dmSansBold(28))
                                .foregroundStyle(MemoMapTheme.black)

                        }
                        .padding(.top, 30)
                        .padding(.bottom ,25)

                        VStack(alignment: .leading, spacing:11) {

                            Text("Email adress")
                                .font(MemoFont.dmSansMedium(14))
                                .foregroundStyle(MemoMapTheme.black)

                            HStack(spacing: 11) {

                               Image(systemName: "envelope")
                                   .font(.system(size: 16))
                                   .foregroundStyle(MemoMapTheme.green)
                                   .frame(width: 20)

                               TextField(
                                   "you@example.com",
                                   text: $email
                               )
                               .font(MemoFont.dmSansRegular(14))
                               .foregroundStyle(MemoMapTheme.black)
//                               .textContentType(.emailAddress)
                               .textInputAutocapitalization(.never)
                               .keyboardType(.emailAddress)
                               .autocorrectionDisabled()
                               .submitLabel(.next)
                           }
                           .padding(.horizontal, 15)
                           .frame(height: 52)
                           .background(MemoMapTheme.inputBackground)
                           .clipShape(
                               RoundedRectangle(cornerRadius: 12)
                           )
                           .overlay {
                               RoundedRectangle(cornerRadius: 12)
                                   .stroke(
                                       MemoMapTheme.inputBorder,
                                       lineWidth: 0.7
                                   )
                           }
                       }

                        VStack(alignment: .leading, spacing: 9) {
                            
                            Text("Password")
                            .font(MemoFont.dmSansMedium(14))
                            .foregroundStyle(MemoMapTheme.black)


                            HStack(spacing: 11) {

                           Image(systemName: "lock")
                               .font(.system(size: 16))
                               .foregroundStyle(MemoMapTheme.green)
                               .frame(width: 20)

                           Group {
                               if isPasswordVisible {
                                   TextField(
                                       "Enter your password",
                                       text: $password
                                   )
                               } else {
                                   SecureField(
                                       "Enter your password",
                                       text: $password
                                   )
                               }
                           }
                           .font(MemoFont.dmSansRegular(14))
                           .foregroundStyle(MemoMapTheme.black)
                           .textContentType(.password)
                           .textInputAutocapitalization(.never)
                           .autocorrectionDisabled()
                           .submitLabel(.go)
                           .onSubmit {
                               signIn()
                           }

                           Button {
                               isPasswordVisible.toggle()
                           } label: {
                               Image(
                                   systemName: isPasswordVisible
                                       ? "eye.slash"
                                       : "eye"
                               )
                               .font(.system(size: 15))
                               .foregroundStyle(
                                   MemoMapTheme.Textsecondary
                               )
                           }
                           .buttonStyle(.plain)
                           .accessibilityLabel(
                               isPasswordVisible
                                   ? "Hide password"
                                   : "Show password"
                           )
                       }
                       .padding(.horizontal, 15)
                       .frame(height: 52)
                       .background(MemoMapTheme.inputBackground)
                       .clipShape(
                           RoundedRectangle(cornerRadius: 12)
                       )
                       .overlay {
                           RoundedRectangle(cornerRadius: 12)
                               .stroke(
                                   MemoMapTheme.inputBorder,
                                   lineWidth: 0.7
                               )
                       }
                   }
                   .padding(.top, 20)

                   if !auth.errormessage.isEmpty {

                       Text(auth.errormessage)
                           .font(MemoFont.dmSansRegular(12))
                           .foregroundStyle(.red)
                           .fixedSize(
                               horizontal: false,
                               vertical: true
                           )
                           .padding(.top, 12)
                   }

                   Button {
                       signIn()
                   } label: {

                       HStack(spacing: 10) {

                           if auth.isLoading {

                               ProgressView()
                                   .tint(MemoMapTheme.White)

                           } else {

                               Text("Sign In")
                                   .font(MemoFont.dmSansBold(16))

//                               Image(systemName: "arrow.right")
//                                   .font(.system(size: 14, weight: .semibold))
                           }
                       }
                       .foregroundStyle(MemoMapTheme.White)
                       .frame(maxWidth: .infinity)
                       .frame(height: 56)
                       .background(MemoMapTheme.green)
                       .clipShape(Capsule())
                   }
                   .buttonStyle(.plain)
                   .disabled(auth.isLoading)
                   .opacity(auth.isLoading ? 0.75 : 1)
                   .padding(.top, 40)

                   HStack(spacing: 5) {

                       Text("New to here?")
                           .foregroundStyle(
                               MemoMapTheme.Textsecondary
                           )
                           .font(MemoFont.dmSansMedium(13))


                       NavigationLink {
                           RegisterView()
                       } label: {

                           Text("Create account")
                               .font(MemoFont.dmSansBold(13))
                               .foregroundStyle(MemoMapTheme.green)
                       }
                   }
                   .frame(maxWidth: .infinity)
                   .padding(.top, 40)
                   .padding(.bottom, 30)
               }
               .padding(.horizontal, 28)
           }
           .scrollDismissesKeyboard(.interactively)
       }
       .toolbar(.hidden, for: .navigationBar)
   }
}

private func signIn() {

   guard !auth.isLoading else { return }

   Task {
       await auth.login(
           email: email.trimmingCharacters(
               in: .whitespacesAndNewlines
           ),
           password: password
       )
   }
}
}

#Preview {
LoginView()
   .environmentObject(AuthViewModel())
}
