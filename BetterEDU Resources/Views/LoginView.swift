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
            ZStack {
                // Use "lavabackground" image as the background
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                
                ScrollView { // Wrap in a ScrollView to prevent content from being pushed off-screen
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image("BetterLogo2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250) // Adjust size of the logo
                            .padding(.top, -10)
                        
                        Text("Your Journey to Wellness Starts Here")
                            .font(.custom("Impact", size: 22))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.top, 10)

                        VStack(alignment: .leading, spacing: 16) {
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

                        // Sign In Button
                        Button(action: { signInUser(asGuest: false) }) {
                            Text("Sign In")
                                .font(.custom("Impact", size: 22)) // Reduce font size
                                .frame(maxWidth: .infinity) // Adjust max width if needed
                                .padding(12) // Reduce padding
                                .background(Color(hex: "5a0ef6"))
                                .foregroundColor(.white)
                                .cornerRadius(8) // Slightly smaller corner radius
                                .padding(.horizontal, 12) // Reduce horizontal padding
                        }
                        .padding(.top, 10) // Reduce top padding

                        // Continue as Guest Button
                        Button(action: { signInUser(asGuest: true) }) {
                            Text("Continue as Guest")
                                .font(.custom("Impact", size: 22)) // Reduce font size
                                .frame(maxWidth: .infinity) // Adjust max width if needed
                                .padding(12) // Reduce padding
                                .background(Color(hex: "5a0ef6"))
                                .foregroundColor(.white)
                                .cornerRadius(8) // Slightly smaller corner radius
                                .padding(.horizontal, 12) // Reduce horizontal padding
                        }

                        // Error Message Placeholder (Reserve space)
                        Text(errorMessage ?? " ")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 16)

                        // "Not a member?" and "Sign Up" section
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
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, -25) // Move it higher with top padding

                        Spacer()
                    }
                    .padding()
                }
                .fullScreenCover(isPresented: $isLoggedIn) {
                    HomePageView()
                }
            }
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
