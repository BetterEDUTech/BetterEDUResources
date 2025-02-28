//
//  AcademicStressView.swift
//  BetterEDU Resources
//
//  Created by Nick Arana on 11/5/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct AcademicStressView: View {
    @State private var searchText = ""
    @State private var academicResources: [ResourceItem] = [] // Dynamic resources fetched from Firestore
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text("Academic Stress Support")
                .font(.custom("Impact", size: 35))
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
        .navigationTitle("Academic Stress Support")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: fetchAcademicResources)
    }

    // Fetch academic resources from Firestore
    private func fetchAcademicResources() {
        db.collection("resourcesApp")
            .whereField("Resource Type", isEqualTo: "academic")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching academic resources: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    self.academicResources = documents.compactMap { document in
                        try? document.data(as: ResourceItem.self)
                    }
                }
            }
    }

    // Filter resources based on search text
    private var filteredResources: [ResourceItem] {
        academicResources.filter { resource in
            searchText.isEmpty || resource.title.lowercased().contains(searchText.lowercased())
        }
    }
}

struct AcademicStressView_Previews: PreviewProvider {
    static var previews: some View {
        AcademicStressView()
    }
}

