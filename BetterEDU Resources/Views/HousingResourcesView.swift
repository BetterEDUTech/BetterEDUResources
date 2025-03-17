//
//  HousingResourcesView.swift
//  BetterEDU Resources
//
//  Created by Connor Ott on 3/10/25.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct HousingResourcesView: View {
    @State private var searchText = ""
    @State private var HousingResources: [ResourceItem] = [] // Dynamic resources fetched from Firestore
    @State private var userState: String = "ALL"        // User's selected state
    private let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text("Housing & Shelter Resources")
                .font(.custom("Impact", size: 30))
                .foregroundColor(Color(hex: "#FFFFFF"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)

            // Search Bar
            TextField("Search Resources", text: $searchText)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)

            // Resource List
            ScrollView {
                LazyVStack(spacing: 16) {
                    if filteredResources.isEmpty {
                        Text("No resources found.")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(filteredResources) { resource in
                            ResourceCard(resource: resource)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
        .padding()
        .background(
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationTitle("Housing & Shelter Resources")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUserData()
            fetchHaSResources()
        }
    }

    // Fetch self-care resources from Firestore
    private func fetchHaSResources() {
        db.collection("resourcesApp")
            .whereField("Resource Type", isEqualTo: "housing")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching self-care resources: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    self.HousingResources = documents.compactMap { document in
                        try? document.data(as: ResourceItem.self)
                    }
                }
            }
    }

    // Filter resources based on search text and state
    private var filteredResources: [ResourceItem] {
        HousingResources.filter { resource in
            let matchesSearch = searchText.isEmpty || resource.title.lowercased().contains(searchText.lowercased())
            let matchesState = resource.state == "ALL" || resource.state == userState
            return matchesSearch && matchesState
        }
    }

    // Load user's profile data from Firestore
    private func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error loading user data: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists,
               let state = document.data()?["location"] as? String {
                // Convert state name to abbreviation
                DispatchQueue.main.async {
                    self.userState = state == "Arizona" ? "AZ" : state == "California" ? "CA" : "ALL"
                }
            }
        }
    }
}


struct HousingResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        HousingResourcesView()
    }
}
