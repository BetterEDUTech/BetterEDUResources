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
            ZStack {
                // Background image
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()


                VStack(spacing: 20) {
                    Spacer()

                    // BetterLogo2 at the top
                    Image("BetterLogo2")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.top, -50)

                    // Title
                    Text("Create an Account")
                        .font(.custom("Impact", size: 24))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)

                    // Input fields styled like LoginView
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Name")
                                .font(.custom("Impact", size: 18))
                                .foregroundColor(.white)
                            TextField("Enter your name", text: $name)
                                .padding()
                                .background(Color(hex: "98b6f8"))
                                .cornerRadius(10)
                                .foregroundColor(Color(hex: "251db4"))
                                .frame(maxWidth: .infinity)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Email")
                                .font(.custom("Impact", size: 18))
                                .foregroundColor(.white)
                            TextField("name@example.com", text: $email)
                                .padding()
                                .background(Color(hex: "98b6f8"))
                                .cornerRadius(10)
                                .foregroundColor(Color(hex: "251db4"))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .frame(maxWidth: .infinity)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Password")
                                .font(.custom("Impact", size: 18))
                                .foregroundColor(.white)
                            ZStack(alignment: .trailing) {
                                if isPasswordVisible {
                                    TextField("Password", text: $password)
                                        .padding()
                                        .background(Color(hex: "98b6f8"))
                                        .cornerRadius(10)
                                        .foregroundColor(Color(hex: "251db4"))
                                        .frame(maxWidth: .infinity)
                                } else {
                                    SecureField("Password", text: $password)
                                        .padding()
                                        .background(Color(hex: "98b6f8"))
                                        .cornerRadius(10)
                                        .foregroundColor(Color(hex: "251db4"))
                                        .frame(maxWidth: .infinity)
                                }
                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing, 10)
                            }
                        }
                    }
                    .padding(.horizontal, 16) // Add consistent horizontal padding for all fields

                    // Sign Up Button styled like Sign In
                    Button(action: { signUpUser() }) {
                        Text("Sign Up")
                            .font(.custom("Impact", size: 30))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "5a0ef6"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 16) // Add consistent horizontal padding for the button

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 16) // Add consistent padding for the error message
                    }

                    Spacer()
                }
                .padding()
                .fullScreenCover(isPresented: $isSignedUp) {
                    HomePageView()
                }
            }
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
