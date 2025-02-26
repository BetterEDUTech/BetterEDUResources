import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errorMessage: String?
    @State private var isLoggedIn = false
    @State private var keyboardHeight: CGFloat = 0
    @Environment(\.horizontalSizeClass) var sizeClass

    // Custom text field modifier
    private func customTextField(_ text: String) -> some View {
        Group {
            if text == "Password" && !isPasswordVisible {
                SecureField("", text: $password)
            } else if text == "Password" && isPasswordVisible {
                TextField("", text: $password)
            } else {
                TextField("", text: $email)
            }
        }
        .padding()
        .foregroundColor(.black)
        .background(Color.white.opacity(0.9))
        .cornerRadius(25)
        .overlay(
            Text(text)
                .foregroundColor(Color.black.opacity(0.6))
                .padding(.leading, 16)
                .opacity(text == "Password" ? (password.isEmpty ? 1 : 0) : (email.isEmpty ? 1 : 0)),
            alignment: .leading
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: sizeClass == .regular ? 30 : 20) {
                            Image("BetterLogo2")
                                .resizable()
                                .scaledToFit()
                                .frame(height: sizeClass == .regular ? 300 : 200)
                                .padding(.top, sizeClass == .regular ? 40 : 20)

                            Text("Your Journey to Wellness Starts Here")
                                .font(.custom("Impact", size: sizeClass == .regular ? 30 : 22))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            // Form fields
                            formFields()

                            // Action buttons
                            actionButtons()

                            // Error message and sign-up link
                            footerSection()
                        }
                        .padding(.horizontal, sizeClass == .regular ? 40 : 16)
                        .frame(maxWidth: sizeClass == .regular ? 700 : 600)
                        .padding(.bottom, keyboardHeight)
                        .animation(.easeOut(duration: 0.3), value: keyboardHeight)
                    }

                    Spacer()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear { addKeyboardObservers() }
        .onDisappear { removeKeyboardObservers() }
        .fullScreenCover(isPresented: $isLoggedIn) {
            HomePageView()
        }
    }

    // MARK: - Form Fields
    @ViewBuilder
    private func formFields() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            fieldLabel("Email")
            customTextField("Email")
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            fieldLabel("Password")
            ZStack(alignment: .trailing) {
                customTextField("Password")
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.black)
                        .padding(.trailing, 16)
                }
            }

            NavigationLink(destination: ForgotPasswordView()) {
                Text("Forgot Password?")
                    .font(.custom("Impact", size: 16))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, sizeClass == .regular ? 24 : 16)
        .frame(maxWidth: sizeClass == .regular ? 700 : 350)
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private func actionButtons() -> some View {
        VStack(spacing: 12) {
            Button(action: { signInUser(asGuest: false) }) {
                Text("Sign In")
                    .font(.custom("Impact", size: sizeClass == .regular ? 26 : 22))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "5a0ef6"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: { signInUser(asGuest: true) }) {
                Text("Continue as Guest")
                    .font(.custom("Impact", size: sizeClass == .regular ? 26 : 22))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "5a0ef6"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: sizeClass == .regular ? 700 : 350)
        .padding(.horizontal, sizeClass == .regular ? 24 : 16)
    }

    // MARK: - Footer Section
    @ViewBuilder
    private func footerSection() -> some View {
        VStack(spacing: 15) {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            HStack {
                Text("Not a member?")
                    .foregroundColor(.white)
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .bold()
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, sizeClass == .regular ? 30 : 20)
    }

    // MARK: - Helpers
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.custom("Impact", size: sizeClass == .regular ? 20 : 18))
            .foregroundColor(.white)
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func signInUser(asGuest: Bool) {
        if asGuest {
            Auth.auth().signInAnonymously { _, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    isLoggedIn = true
                }
            }
        } else {
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Please enter your email and password."
                return
            }

            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    isLoggedIn = true
                }
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

