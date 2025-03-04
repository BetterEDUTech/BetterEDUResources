import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct SavedView: View {
    @State private var savedResources: [SavedResourceItem] = []
    @State private var profileImage: UIImage? = nil
    @State private var searchText: String = ""
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header with profile icon
                HStack {
                    NavigationLink(destination: ProfileView().navigationBarHidden(true)) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 4)
                                .padding(.leading, 16)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.white)
                                .padding(.leading, 16)
                        }
                    }
                    Spacer()
                }
                .padding(.top)

                // Title
                Text("Saved Resources")
                    .font(.custom("Lobster1.4", size: 60))
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
                            .foregroundColor(.black)
                            .tint(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                    // Filter Button
                    Menu {
                        Button("All", action: {})
                        Button("Emergency", action: {})
                        Button("Financial", action: {})
                        Button("Mental Health", action: {})
                    } label: {
                        Text("All")
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // Resources List
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(filteredResources) { resource in
                            SavedResourceCard(resource: resource, onRemove: { removedResource in
                                if let index = savedResources.firstIndex(where: { $0.id == removedResource.id }) {
                                    savedResources.remove(at: index)
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 90) // Add padding at bottom to account for tab bar
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadProfileImage()
            fetchSavedResources()
        }
    }

    private var filteredResources: [SavedResourceItem] {
        if searchText.isEmpty {
            return savedResources
        } else {
            return savedResources.filter { resource in
                resource.title.lowercased().contains(searchText.lowercased())
            }
        }
    }

    // Fetch saved resources from Firestore
    private func fetchSavedResources() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            return
        }

        db.collection("users").document(uid).collection("savedResources").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching saved resources: \(error.localizedDescription)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No saved resources found.")
                return
            }

            // Decode documents into SavedResourceItem objects
            self.savedResources = documents.compactMap { document in
                do {
                    return try document.data(as: SavedResourceItem.self)
                } catch {
                    print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                    return nil
                }
            }

            DispatchQueue.main.async {
                print("Fetched saved resources: \(self.savedResources)")
            }
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

// New SavedResourceItem Model
struct SavedResourceItem: Identifiable, Codable {
    @DocumentID var id: String?          // Firebase Document ID
    var title: String                    // Resource Title
    var phone_number: String             // Resource Phone Number
    var website: String?                 // Resource Website URL (optional)
    var resourceType: String             // Resource Type (e.g., "self care", "financial")
}

// View for displaying saved resources
struct SavedResourceCard: View {
    let resource: SavedResourceItem
    @State private var isLiked: Bool = false
    private let db = Firestore.firestore()
    let onRemove: (SavedResourceItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(resource.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            if !resource.phone_number.isEmpty {
                Text("Phone: \(resource.phone_number)")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }

            if let website = resource.website, !website.isEmpty {
                Link("Visit Website", destination: URL(string: website)!)
                    .font(.system(size: 15))
                    .foregroundColor(.blue)
            } else {
                Text("Website unavailable")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }

            HStack {
                Spacer()
                Button(action: toggleSaveResource) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                        .font(.system(size: 20))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
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
            // If liked, remove from saved resources
            resourceRef.delete { error in
                if error == nil {
                    DispatchQueue.main.async {
                        isLiked = false
                        onRemove(resource) // Notify parent view about the removal
                    }
                }
            }
        } else {
            // If not liked, add to saved resources
            let resourceData: [String: Any] = [
                "id": resource.id ?? "",
                "title": resource.title,
                "phone_number": resource.phone_number,
                "website": resource.website ?? "",
                "resourceType": resource.resourceType
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

// Preview for SavedView
struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        SavedView()
    }
}
