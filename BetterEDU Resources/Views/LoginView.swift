import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errorMessage: String?
    @State private var isLoggedIn = false
    //@State private var guest = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Add some top padding to prevent content from being under status bar
                            Color.clear.frame(height: 20)
                            
                            // Logo section with adaptive sizing
                            Image("BetterLogo2")
                                .resizable()
                                .scaledToFit()
                                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200)
                                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 0)
                            
                            Text("Your Journey to Wellness Starts Here")
                                .font(.custom("Impact", size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 22))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.bottom, 20)
                            
                            // Form fields with adaptive width
                            VStack(alignment: .leading, spacing: 20) {
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

                                        Button(action: {
                                            isPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(Color(hex: "251db4"))
                                                .padding(.trailing, 26) // Align with padding
                                        }
                                    }
                                }

                                // Forgot Password Link
                                NavigationLink(destination: ForgotPasswordView()) {
                                    Text("Forgot Password?")
                                        .font(.custom("Impact", size: 16))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16) // Align with text fields
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.6 : .infinity)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 15)
                            
                            // Buttons with adaptive width
                            Group {
                                Button(action: { signInUser(asGuest: false) }) {
                                    Text("Sign In")
                                        .font(.custom("Impact", size: UIDevice.current.userInterfaceIdiom == .pad ? 26 : 22))
                                        .frame(maxWidth: .infinity)
                                        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
                                        .background(Color(hex: "5a0ef6"))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                
                                Button(action: { signInUser(asGuest: true) }) {
                                    Text("Continue as Guest")
                                        .font(.custom("Impact", size: UIDevice.current.userInterfaceIdiom == .pad ? 26 : 22))
                                        .frame(maxWidth: .infinity)
                                        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
                                        .background(Color(hex: "5a0ef6"))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.6 : .infinity)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 25)
                            
                            // Error Message Placeholder (Reserve space)
                            VStack(spacing: 15) {
                                Text(errorMessage ?? " ")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 16)
                                
                                HStack(spacing: 5) {
                                    Text("Not a member?")
                                        .font(.custom("Impact", size: 22))
                                        .italic()
                                        .foregroundColor(.white)
                                    
                                    NavigationLink(destination: SignUpView()) {
                                        Text("Sign Up")
                                            .font(.custom("Impact", size: 22))
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.vertical, 20)
                            
                            // Add bottom padding to ensure content isn't cut off
                            Color.clear.frame(height: 40)
                        }
                        .frame(minHeight: geometry.size.height)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // This helps with iPad layout
        .fullScreenCover(isPresented: $isLoggedIn) {
            HomePageView()
        }
    }
    
    private func signInUser(asGuest: Bool) {
        if asGuest {
            // Sign in anonymously as a guest
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isLoggedIn = true
                }
            }
        } else {
            // Regular sign-in with email and password
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Please enter your email and password."
                return
            }

            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isLoggedIn = true
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
