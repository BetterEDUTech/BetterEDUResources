//
//  ProfileView.swift
//  BetterEDU Resources
//
//  Created by Nick Arana on 10/29/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "251db4")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header Section with Close Button
                HStack {
                    Spacer()
                    Button(action: {
                        // Action to close or navigate back
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.trailing)

                // Profile Icon
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)

                // Name Text
                Text("[Name]")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()

                // List of Profile Options
                VStack(spacing: 20) {
                    profileRow(icon: "person.fill", text: "Personal Information")
                    profileRow(icon: "mappin.circle.fill", text: "Location")
                    profileRow(icon: "graduationcap.fill", text: "Set School")
                    profileRow(icon: "heart.fill", text: "Saved Resources")
                }
                .padding(.horizontal)

                Spacer()

                // Settings Button
                Button(action: {
                    // Navigate to Settings
                }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding()
                }

                Spacer()
            }
        }
    }

    // Helper function to create profile rows
    private func profileRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
                .fontWeight(.bold)
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    ProfileView()
}


