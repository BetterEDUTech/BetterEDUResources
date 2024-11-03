import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
        ZStack {
            // Set the background color to match your mockup
            Color(hex: "251db4")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer()
                Image("BetterLogo") // Use the name of your image set
                    .resizable() // Make the image resizable if needed
                    .aspectRatio(contentMode: .fit) // Maintain the aspect ratio
                   //  .frame(width: 400, height: 100) // Set the desired frame size
                  // "betterEDU" text placeholder for the logo
                  //text("BetterEDU")
                 //.font(.custom("Impact", size: 70))
                 // .foregroundColor(.white)

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

                // Forgot Password and Sign Up
                HStack {
                    Button(action: {
                        // Forgot password action
                    }) {
                        Text("Forgot Password?")
                            .font(.custom("Impact", size: 16))
                            .foregroundColor(.white)
                            .font(.footnote)
                    }
                    Spacer()
                    Button(action: {
                        // Sign Up action
                    }) {
                        Text("Sign Up")
                            .font(.custom("Impact", size: 16))
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
