//
//  PersonalInfoView.swift
//  BetterEDU Resources
//
//  Created by Nick Arana on 10/31/24.
//

import SwiftUI

struct PersonalInformationView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    
    // Dismiss action to navigate back
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Background color
            Color(hex: "251db4")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                
                // Custom Back Arrow in the Top-Left Corner
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                    Spacer()
                }
                .padding([.top, .leading])

                Text("Personal Information")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, -10)

                // Name Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Name")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    TextField("Enter your name", text: $name)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Email Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
                
                // Save Button
                Button(action: {
                    // Save action for name and email
                    savePersonalInformation()
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationBarHidden(true) // Hide the default navigation bar
        }
    }
    
    // Placeholder function to handle save action
    private func savePersonalInformation() {
        // Code to save the name and email, e.g., storing in UserDefaults or database
        print("Saved Name: \(name), Email: \(email)")
    }
}

#Preview {
    PersonalInformationView()
}
