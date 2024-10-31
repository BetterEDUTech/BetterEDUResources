//
//  LocationView.swift
//  BetterEDU Resources
//
//  Created by Nick Arana on 10/31/24.
//

import SwiftUI

struct LocationView: View {
    @State private var selectedState: String = ""
    @State private var searchText: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    // Sample list of states (you can expand this as needed)
    let states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

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

                Text("Set Location")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, -10)

                // Search Field
                TextField("Search for your state", text: $searchText)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
                // Filtered List of States
                List {
                    ForEach(filteredStates, id: \.self) { state in
                        Button(action: {
                            selectedState = state
                        }) {
                            HStack {
                                Text(state)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedState == state {
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
                    saveLocation()
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
    
    // Filter states based on the search text
    private var filteredStates: [String] {
        if searchText.isEmpty {
            return states
        } else {
            return states.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Placeholder function to handle save action
    private func saveLocation() {
        // Code to save the selected location, e.g., storing in UserDefaults or database
        print("Saved Location: \(selectedState)")
    }
}

#Preview {
    LocationView()
}
