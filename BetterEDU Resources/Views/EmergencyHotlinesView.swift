import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct EmergencyHotlinesView: View {
    @State private var searchText = ""
    @State private var emergencyHotlines: [ResourceItem] = [] // Dynamic resources fetched from Firestore
    @State private var userState: String = "ALL"        // User's selected state
    private let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text("Emergency Hotlines")
                .font(.custom("Impact", size: 35))
                .foregroundColor(Color(hex: "#FFFFFF"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)

            // Search Bar
            
            TextField("Search Hotlines", text: $searchText)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)

            // Hotline List
            ScrollView {
                LazyVStack(spacing: 16) {
                    if filteredHotlines.isEmpty {
                        Text("No hotlines found.")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(filteredHotlines) { hotline in
                            ResourceCard(resource: hotline)
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
        .navigationTitle("Emergency Hotlines")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUserData()
            fetchEmergencyHotlines()
        }
    }

    // Fetch emergency hotlines from Firestore
    private func fetchEmergencyHotlines() {
        db.collection("resourcesApp")
            .whereField("Resource Type", isEqualTo: "emergency")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching emergency hotlines: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    self.emergencyHotlines = documents.compactMap { document in
                        try? document.data(as: ResourceItem.self)
                    }
                }
            }
    }

    // Filter hotlines based on search text and state
    private var filteredHotlines: [ResourceItem] {
        emergencyHotlines.filter { hotline in
            let matchesSearch = searchText.isEmpty || hotline.title.lowercased().contains(searchText.lowercased())
            let matchesState = hotline.state == "ALL" || hotline.state == userState
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

struct EmergencyHotlinesView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyHotlinesView()
    }
}
