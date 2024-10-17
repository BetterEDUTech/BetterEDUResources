import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
        ZStack {
            // Set the background color to match your mockup
            Color(red: 3/255, green: 19/255, blue: 43/255)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer()

                // "better" text placeholder for the logo (adjust font to match closely)
                Text("better")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Sign In")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 10)

                // Email TextField
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email")
                        .foregroundColor(.white)
                    TextField("name@example.com", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                // Password SecureField with show/hide toggle
                VStack(alignment: .leading, spacing: 10) {
                    Text("Password")
                        .foregroundColor(.white)

                    ZStack(alignment: .trailing) {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        } else {
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
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
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)

                // Forgot Password and Sign Up
                HStack {
                    Button(action: {
                        // Forgot password action
                    }) {
                        Text("Forgot Password?")
                            .foregroundColor(.white)
                            .font(.footnote)
                    }
                    Spacer()
                    Button(action: {
                        // Sign Up action
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .font(.footnote)
                    }
                }
                .padding(.top, 10)

                Spacer()

            }
            .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
