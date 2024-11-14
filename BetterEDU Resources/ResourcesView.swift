import SwiftUI
import Firebase
import FirebaseFirestore

// Define your ResourceItem model with phone_number, title, and website
struct ResourceItem: Identifiable, Codable {
    @DocumentID var id: String?         // Firebase Document ID
    var title: String                   // Resource Title
    var phone_number: String            // Resource Phone Number
    var website: String                 // Resource Website URL
}

struct ResourcesAppView: View {
    @State private var resources: [ResourceItem] = []   // State array for resources
    @State private var searchText: String = ""          // State for the search text
    private var db = Firestore.firestore()
    
    @State private var isShowingHomePage = false
    @State private var isShowingResources = false
    @State private var isShowingSaved = false
    @State private var isShowingFeedback = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Title
                Text("Resources")
                    .font(.custom("Impact", size: 48))
                    .foregroundColor(.white)
                    .padding(.top, 20)  // Space from the top of the screen
                    .frame(maxWidth: .infinity, alignment: .center) // Center align the title

                // Search Bar below the title
                TextField("Search Resources...", text: $searchText)
                    .padding(10)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 10) // Space between title and search bar

                Spacer()
                
                Text("Resources Coming Soon!")
                    .font(.custom("Impact", size: 64))
                    .fontWeight(.bold)
                    .foregroundColor(.white) // color for the text
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
                
                // Bottom Navigation Bar
                HStack {
                    Spacer()
                    navBarButton(icon: "house", label: "Home") {
                        if !isShowingHomePage {
                            isShowingHomePage = true
                        }
                    }
                    .fullScreenCover(isPresented: $isShowingHomePage) {
                        HomePageView()
                    }
                    Spacer()
                    navBarButton(icon: "magnifyingglass", label: "Search") {
                        // Do nothing if already on Resources page
                    }
                    Spacer()
                    navBarButton(icon: "heart.fill", label: "Saved") {
                        if !isShowingSaved {
                            isShowingSaved = true
                        }
                    }
                    .fullScreenCover(isPresented: $isShowingSaved) {
                        SavedView()
                    }
                    Spacer()
                    navBarButton(icon: "bubble.left.and.bubble.right", label: "Feedback") {
                        if !isShowingFeedback {
                            isShowingFeedback = true
                        }
                    }
                    .fullScreenCover(isPresented: $isShowingFeedback) {
                        FeedbackView()
                    }
                    Spacer()
                }
                .padding()
                .background(Color.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Expand to fill the screen
            .background(Color(hex: "251db4"))  // Set the background color using the hex extension
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: fetchResources)
        }
    }

    // Function to fetch resources from Firebase
    private func fetchResources() {
        db.collection("resourcesApp")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                } else {
                    self.resources = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: ResourceItem.self)
                    } ?? []
                }
            }
    }

    // Filtered resources based on search text
    private var filteredResources: [ResourceItem] {
        if searchText.isEmpty {
            return resources
        } else {
            return resources.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
}

// Helper function for the bottom navigation buttons
private func navBarButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        VStack {
            Image(systemName: icon)
            Text(label).font(.footnote)
        }
        .foregroundColor(.white)
    }
}

struct ResourcesAppView_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesAppView()
    }
}
