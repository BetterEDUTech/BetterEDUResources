//
//  ForgotPasswordView.swift
//  BetterEDU Resources
//
//  Created by Nick Arana on 11/4/24.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isRequestSent = false // State to show confirmation message after submitting

    var body: some View {
        ZStack {
            // Background color
            Color(hex: "251db4").ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Title
                Text("Forgot Password")
                    .font(.custom("Impact", size: 28))
                    .foregroundColor(.white)
                    .padding()

                // Instruction Text
                Text("Enter your email to receive reset instructions.")
                    .font(.custom("Impact", size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

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
                .padding(.horizontal)

                // Submit Button
                Button(action: {
                    // Action for sending password reset
                    isRequestSent = true
                }) {
                    Text("Submit")
                        .font(.custom("Impact", size: 24))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Confirmation Message
                if isRequestSent {
                    Text("Password reset instructions have been sent to your email.")
                        .font(.custom("Impact", size: 14))
                        .foregroundColor(.green)
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()
            }
            .padding()
        }
    }
}


struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
