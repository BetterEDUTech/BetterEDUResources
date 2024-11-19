import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

// Define your ResourceItem model with mappings for Firestore field names
struct ResourceItem: Identifiable, Codable {
    @DocumentID var id: String?         // Firebase Document ID
    var title: String                   // Resource Title
    var phone_number: String            // Resource Phone Number
    var website: String?                // Resource Website URL (optional)
    var resourceType: String            // Resource Type (e.g., "self care", "financial")

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case phone_number = "phone number" // Map to "phone number" in Firestore
        case website
        case resourceType = "Resource Type" // Map to "Resource Type" in Firestore
    }
}

struct ResourcesAppView: View {
    @State private var resources: [ResourceItem] = []   // State array for resources
    @State private var searchText: String = ""          // State for the search text
    @State private var selectedFilter: String = "All"   // Default filter for resources
    @State private var availableFilters: [String] = ["All"] // Filters from Firebase
    private var db = Firestore.firestore()
    
    @State private var isShowingHomePage = false
    @State private var isShowingResources = false
    @State private var isShowingSaved = false
    @State private var isShowingFeedback = false
    @State private var profileImage: UIImage? = nil // State to store the profile image

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header with profile icon
                HStack {
                    NavigationLink(destination: ProfileView()) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 4)
                                .padding(.leading)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.white)
                                .padding(.leading)
                        }
                    }
                    Spacer()
                }
                .padding(.top)
                .onAppear(perform: {
                    loadProfileImage()
                    fetchResources()
                }) // Load profile image and fetch resources on appear
                
                // Title
                Text("Resources")
                    .font(.custom("Impact", size: 48))
                    .foregroundColor(.white)
                    .padding(.top, 20)  // Space from the top of the screen
                    .frame(maxWidth: .infinity, alignment: .center) // Center align the title

                // Search Bar and Filter Dropdown
                HStack(spacing: 10) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search Resources...", text: $searchText)
                            .padding(.vertical, 8)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                    // Filter Button
                    Menu {
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(availableFilters, id: \.self) { filter in
                                Text(filter).tag(filter)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedFilter)
                                .font(.callout)
                                .foregroundColor(.white)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10) // Add space between title and search bar

                // Display filtered resources
                ScrollView {
                    LazyVStack(spacing: 16) { // Use LazyVStack for better performance
                        if filteredResources.isEmpty {
                            Text("No resources found.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(filteredResources) { resource in
                                ResourceCard(resource: resource) // Updated card with like functionality
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 12)
                }

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
        }
    }

    // Function to fetch resources from Firebase
    private func fetchResources() {
        db.collection("resourcesApp")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("No documents found in resourcesApp.")
                        return
                    }
                    self.resources = documents.compactMap { document in
                        do {
                            let resource = try document.data(as: ResourceItem.self)
                            return resource
                        } catch {
                            print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                            return nil
                        }
                    }
                    updateAvailableFilters()
                }
            }
    }

    // Update available filters based on resources
    private func updateAvailableFilters() {
        let types = Set(resources.map { $0.resourceType })
        availableFilters = ["All"] + Array(types).sorted()
    }

    // Filtered resources based on search text and selected filter
    private var filteredResources: [ResourceItem] {
        resources.filter { resource in
            let matchesFilter = (selectedFilter == "All" || resource.resourceType == selectedFilter)
            let matchesSearch = searchText.isEmpty || resource.title.lowercased().contains(searchText.lowercased())
            return matchesFilter && matchesSearch
        }
    }

    // Function to load the user's profile image from Firestore
    private func loadProfileImage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error loading profile image URL: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists,
               let profileImageURLString = document.data()?["profileImageURL"] as? String,
               let url = URL(string: profileImageURLString) {
                
                fetchImage(from: url)
            }
        }
    }
    
    // Helper function to fetch an image from a URL
    private func fetchImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching profile image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = uiImage
                }
            }
        }.resume()
    }
}

// ResourceCard View with Heart Button
struct ResourceCard: View {
    let resource: ResourceItem
    @State private var isLiked: Bool = false // Track liked state for each resource

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(resource.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Text("Phone: \(resource.phone_number)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)

                if let website = resource.website, !website.isEmpty {
                    Link("Visit Website", destination: URL(string: website)!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            Spacer()

            // Heart Button
            Button(action: {
                isLiked.toggle() // Toggle the liked state
            }) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .red : .gray) // Red when liked, gray otherwise
                    .font(.title3)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
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
