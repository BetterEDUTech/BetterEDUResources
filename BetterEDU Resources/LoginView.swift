//
//  LoginView.swift
//  BetterEDU Resources
//
//  Created by McTyler Tong on 10/16/24.
//


import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            
            //This "better" will be changed to the custom image/logo
            Text("better")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.blue)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

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

            HStack {
                Button(action: {
                    // Forgot password action
                }) {
                    Text("Forgot Password?")
                }
                Spacer()
                Button(action: {
                    // Sign Up action
                }) {
                    Text("Sign Up")
                }
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
