//
//  SetSchoolView.swift
//  BetterEDU Resources
//
//  Created by Nick Arana on 10/31/24.
//

import SwiftUI

struct SetSchoolView: View {
    @State private var selectedCollege: String = ""
    @State private var searchText: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    // List of colleges in California and Arizona
    let colleges = [
        // California Colleges
        "Stanford University", "California Institute of Technology", "University of California, Berkeley",
        "University of Southern California", "University of California, Los Angeles",
        "University of California, San Diego", "University of California, Irvine",
        "University of California, Davis", "University of California, Santa Barbara",
        "San Diego State University", "California State University, Fullerton",
        "California Polytechnic State University, San Luis Obispo", "Santa Clara University",
        
        // Arizona Colleges
        "Arizona State University", "University of Arizona", "Northern Arizona University"
    ]

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

                Text("Set School")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, -10)

                // Search Field
                TextField("Search for your college", text: $searchText)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
                // Filtered List of Colleges
                List {
                    ForEach(filteredColleges, id: \.self) { college in
                        Button(action: {
                            selectedCollege = college
                        }) {
                            HStack {
                                Text(college)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedCollege == college {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .cornerRadius(10)
                
                Spacer()

                // Save Button
                Button(action: {
                    saveCollege()
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
            .navigationBarHidden(true)
        }
    }
    
    // Filter colleges based on the search text
    private var filteredColleges: [String] {
        if searchText.isEmpty {
            return colleges
        } else {
            return colleges.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Placeholder function to handle save action
    private func saveCollege() {
        // Code to save the selected college, e.g., storing in UserDefaults or database
        print("Saved College: \(selectedCollege)")
    }
}

#Preview {
    SetSchoolView()
}
