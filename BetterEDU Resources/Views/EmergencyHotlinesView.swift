import SwiftUI
import Firebase
import FirebaseFirestore

struct EmergencyHotlinesView: View {
    @State private var searchText = ""
    @State private var emergencyHotlines: [ResourceItem] = [] // Dynamic resources fetched from Firestore
    private let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text("Emergency Hotlines")
                .font(.custom("Impact", size: 30))
                .foregroundColor(Color("98b6f8"))
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
        .onAppear(perform: fetchEmergencyHotlines)
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

    // Filter hotlines based on search text
    private var filteredHotlines: [ResourceItem] {
        emergencyHotlines.filter { hotline in
            searchText.isEmpty || hotline.title.lowercased().contains(searchText.lowercased())
        }
    }
}



struct EmergencyHotlinesView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyHotlinesView()
    }
}
