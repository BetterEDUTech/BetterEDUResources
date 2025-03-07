import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errorMessage: String?
    @State private var isSignedUp = false

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background image
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Logo
                            Image("BetterLogo2")
                                .resizable()
                                .scaledToFit()
                                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200)
                                .padding(.top, 20)

                            // Title
                            Text("Create an Account")
                                .font(.custom("Impact", size: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 26))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)

                            // Form fields
                            VStack(spacing: 16) {
                                CustomTextField(label: "Name", placeholder: "Enter your name", text: $name)
                                CustomTextField(label: "Email", placeholder: "name@example.com", text: $email, keyboardType: .emailAddress)
                                CustomSecureField(label: "Password", placeholder: "Password", text: $password, isPasswordVisible: $isPasswordVisible)
                            }
                            .frame(maxWidth: geometry.size.width > 600 ? 700 : 350)
                            .padding(.horizontal)

                            // Sign Up Button
                            Button(action: signUpUser) {
                                Text("Sign Up")
                                    .font(.custom("Impact", size: 22))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "5a0ef6"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .frame(maxWidth: geometry.size.width > 600 ? 700 : 350)
                            .padding(.horizontal)

                            // Error message
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            Spacer(minLength: 20)
                        }
                        .frame(minHeight: geometry.size.height)
                        .padding(.vertical, 30)
                        .frame(maxWidth: geometry.size.width)
                        .multilineTextAlignment(.center)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $isSignedUp) {
            HomePageView()
        }
    }

    private func signUpUser() {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else if let user = authResult?.user {
                self.saveUserData(uid: user.uid)
            }
        }
    }

    private func saveUserData(uid: String) {
        let userData: [String: Any] = [
            "uid": uid,
            "name": name,
            "email": email
        ]

        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                self.errorMessage = "Error saving user data: \(error.localizedDescription)"
            } else {
                self.isSignedUp = true
            }
        }
    }
}

struct CustomTextField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("   \(label)")
                .font(.custom("Impact", size: 18))
                .foregroundColor(.white)
            TextField(placeholder, text: $text)
                .padding()
                .background(Color(hex: "ffffff"))
                .cornerRadius(10)
                .foregroundColor(Color(hex: "251db4"))
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
    }
}

struct CustomSecureField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("   \(label)")
                .font(.custom("Impact", size: 18))
                .foregroundColor(.white)
            ZStack(alignment: .trailing) {
                if isPasswordVisible {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.black)
                        .tint(.black)
                } else {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(.black)
                        .tint(.black)
                }
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(Color(hex: "251db4"))
                        .padding(.trailing, 16)
                }
            }
            .padding()
            .background(Color(hex: "ffffff"))
            .cornerRadius(10)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

