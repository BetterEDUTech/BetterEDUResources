import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
        NavigationView {
            ZStack {
                // Set the background color to match your mockup
                Color(hex: "251db4")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image("BetterLogo") // Use the name of your image set
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100) // Adjust the frame size as needed
                    
                    Text("Sign In to get started")
                        .font(.custom("Impact", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    // Email TextField
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
                    }

                    // Password SecureField with show/hide toggle
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
                            } else {
                                SecureField("Password", text: $password)
                                    .padding()
                                    .background(Color(hex: "98b6f8"))
                                    .cornerRadius(10)
                                    .foregroundColor(Color(hex: "251db4"))
                            }

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 10)
                        }
                    }

                    // Sign In button
                    Button(action: {
                        // Action for login
                    }) {
                        Text("Sign In")
                            .font(.custom("Impact", size: 30))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)

                    // Forgot Password and Sign Up Navigation Links
                    HStack {
                        // Forgot Password Navigation Link
                        NavigationLink(destination: ForgotPasswordView()) {
                            Text("Forgot Password?")
                                .font(.custom("Impact", size: 16))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Sign Up Navigation Link
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                                .font(.custom("Impact", size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .padding()
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
