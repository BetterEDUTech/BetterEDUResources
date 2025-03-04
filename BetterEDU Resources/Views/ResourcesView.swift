import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

// Define ResourceItem model with accurate Firestore field mappings
struct ResourceItem: Identifiable, Codable {
    @DocumentID var id: String?         // Firebase Document ID
    var title: String                   // Resource Title
    var phone_number: String?           // Optional: Resource Phone Number
    var website: String?                // Optional: Resource Website URL
    var resourceType: String?           // Optional: Resource Type (e.g., "self care", "financial")
    var state: String?                  // Optional: State (e.g., "AZ", "CA", "ALL")

    enum CodingKeys: String, CodingKey {
        case id                         // Maps to Firestore document ID
        case title                      // Matches "title" in Firestore
        case phone_number = "phone number" // Matches "phone number" in Firestore
        case website                    // Matches "website" in Firestore
        case resourceType = "Resource Type" // Matches "Resource Type" in Firestore
        case state                      // Matches "state" in Firestore
    }
}

struct ResourcesAppView: View {
    @State private var resources: [ResourceItem] = []   // State array for resources
    @State private var searchText: String = ""          // State for the search text
    @State private var selectedFilter: String = "All"   // Default filter for resources
    @State private var availableFilters: [String] = ["All"] // Filters from Firebase
    @State private var userState: String = "ALL"        // User's selected state
    private let db = Firestore.firestore()
    
    @State private var profileImage: UIImage? = nil // State to store the profile image

    // Grid layout columns based on device
    private var gridColumns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ]
        } else {
            return [GridItem(.flexible())]
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header with profile icon
                HStack {
                    NavigationLink(destination: ProfileView().navigationBarHidden(true)) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 35, 
                                       height: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 35)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 4)
                                .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 35, 
                                       height: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 35)
                                .foregroundColor(.white)
                                .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                        }
                    }
                    Spacer()
                }
                .padding(.top)
                .onAppear(perform: {
                    loadProfileImage()
                    loadUserData()
                    fetchResources()
                })
                
                // Title
                Text("Resources")
                    .font(.custom("Lobster1.4", size: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 60))
                    .foregroundColor(.white)
                    .padding(.top, -1)
                    .padding(.bottom, -10)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Search and Filter Section
                HStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search resources...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    // Filter Menu
                    Menu {
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(availableFilters, id: \.self) { filter in
                                Text(filter).tag(filter)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedFilter)
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14))
                                .foregroundColor(.white)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 12 : 10))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                .padding(.top, 10)

                // Display filtered resources
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16) {
                        if filteredResources.isEmpty {
                            Text("No resources found.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .gridCellColumns(gridColumns.count)
                        } else {
                            ForEach(filteredResources) { resource in
                                ResourceCard(resource: resource)
                            }
                        }
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                    .padding(.top, 12)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )

            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Fetch resources from Firestore
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
                    
                    // Debugging: Log raw Firestore data
                    for document in documents {
                        print("Document data: \(document.data())")
                    }

                    let fetchedResources = documents.compactMap { document in
                        do {
                            return try document.data(as: ResourceItem.self)
                        } catch {
                            print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                            return nil
                        }
                    }
                    DispatchQueue.main.async {
                        self.resources = fetchedResources
                        updateAvailableFilters()
                    }
                }
            }
    }

    // Update available filters based on resources
    private func updateAvailableFilters() {
        let types = Set(resources.compactMap { $0.resourceType })
        availableFilters = ["All"] + Array(types).sorted()
    }

    // Filter resources based on search and filters
    private var filteredResources: [ResourceItem] {
        resources.filter { resource in
            let matchesFilter = (selectedFilter == "All" || resource.resourceType == selectedFilter)
            let matchesSearch = searchText.isEmpty || resource.title.lowercased().contains(searchText.lowercased())
            let matchesState = resource.state == "ALL" || resource.state == userState
            return matchesFilter && matchesSearch && matchesState
        }
    }

    // Load user's profile image from Firestore
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

    // Helper function to fetch an image from URL
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

// ResourceCard View with Safe Optional Unwrapping
struct ResourceCard: View {
    let resource: ResourceItem
    @State private var isLiked: Bool = false
    private let db = Firestore.firestore()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(resource.title)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 17, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                if let phoneNumber = resource.phone_number {
                    Text("Phone: \(phoneNumber)")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 15))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }

                if let website = resource.website, !website.isEmpty, let url = URL(string: website) {
                    Link("Visit Website", destination: url)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 15))
                        .foregroundColor(.blue)
                } else {
                    Text("Website unavailable")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 15))
                        .foregroundColor(.gray)
                }
            }
            Spacer()

            Button(action: toggleSaveResource) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .red : .gray)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20))
            }
        }
        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
        .frame(maxWidth: .infinity, minHeight: UIDevice.current.userInterfaceIdiom == .pad ? 150 : 120)
        .background(Color.black.opacity(0.4))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        .onAppear(perform: checkIfResourceIsSaved)
    }

    // Check if the resource is saved
    private func checkIfResourceIsSaved() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(uid).collection("savedResources").document(resource.id ?? "")

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                DispatchQueue.main.async {
                    isLiked = true
                }
            }
        }
    }

    // Toggle resource save
    private func toggleSaveResource() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let userRef = db.collection("users").document(uid)
        let resourceRef = userRef.collection("savedResources").document(resource.id ?? "")

        if isLiked {
            resourceRef.delete { error in
                if error == nil {
                    DispatchQueue.main.async {
                        isLiked = false
                    }
                }
            }
        } else {
            let resourceData: [String: Any] = [
                "id": resource.id ?? "",
                "title": resource.title,
                "phone_number": resource.phone_number ?? "",
                "website": resource.website ?? "",
                "resourceType": resource.resourceType ?? "",
                "state": resource.state ?? ""
            ]
            resourceRef.setData(resourceData) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        isLiked = true
                    }
                }
            }
        }
    }
}

struct ResourcesAppView_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesAppView()
    }
}
