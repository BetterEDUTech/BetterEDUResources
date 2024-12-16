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
                            // Add top padding
                            Color.clear.frame(height: 20)
                            
                            // Logo with adaptive sizing
                            Image("BetterLogo2")
                                .resizable()
                                .scaledToFit()
                                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200)
                                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 0)
                            
                            // Title with adaptive font
                            Text("Create an Account")
                                .font(.custom("Impact", size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 24))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            // Form fields with adaptive width
                            VStack(spacing: 20) {
                                // Name Field
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("   Name")
                                        .font(.custom("Impact", size: 18))
                                        .foregroundColor(.white)
                                    TextField("Enter your name", text: $name)
                                        .padding()
                                        .background(Color(hex: "98b6f8"))
                                        .cornerRadius(10)
                                        .foregroundColor(Color(hex: "251db4"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 16)
                                }
                                
                                // Email Field
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("   Email")
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
                                        .padding(.horizontal, 16)
                                }
                                
                                // Password Field
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("   Password")
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
                                                .padding(.horizontal, 16)
                                        } else {
                                            SecureField("Password", text: $password)
                                                .padding()
                                                .background(Color(hex: "98b6f8"))
                                                .cornerRadius(10)
                                                .foregroundColor(Color(hex: "251db4"))
                                                .frame(maxWidth: .infinity)
                                                .padding(.horizontal, 16)
                                        }
                                        Button(action: { isPasswordVisible.toggle() }) {
                                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(Color(hex: "251db4"))
                                                .padding(.trailing, 26)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.6 : .infinity)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 15)
                            
                            // Sign Up Button
                            Button(action: { signUpUser() }) {
                                Text("Sign Up")
                                    .font(.custom("Impact", size: UIDevice.current.userInterfaceIdiom == .pad ? 26 : 22))
                                    .frame(maxWidth: .infinity)
                                    .padding(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
                                    .background(Color(hex: "5a0ef6"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.6 : .infinity)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 25)
                            
                            // Error message
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 16)
                            }
                            
                            // Add bottom padding
                            Color.clear.frame(height: 40)
                        }
                        .frame(minHeight: geometry.size.height)
                        .padding(.horizontal)
                    }
                }
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
