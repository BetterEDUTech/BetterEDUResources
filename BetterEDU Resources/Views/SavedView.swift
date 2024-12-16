import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct SavedView: View {
    @State private var savedResources: [SavedResourceItem] = [] // Dynamically fetched saved resources
    @State private var profileImage: UIImage? = nil // State to store the profile image

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 20) {
                            // Add safe area padding at the top
                            Color.clear.frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40)
                            
                            // Header with profile picture
                            HStack {
                                NavigationLink(destination: ProfileView()) {
                                    if let image = profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40,
                                                   height: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 4)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40,
                                                   height: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 30)
                                Spacer()
                            }
                            .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
                            
                            // Title
                            Text("My Saved Resources")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 48 : 40, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                            
                            // Content
                            Group {
                                if savedResources.isEmpty {
                                    Text("No saved resources yet.")
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18))
                                        .foregroundColor(.white)
                                        .padding()
                                } else {
                                    ScrollView {
                                        LazyVGrid(
                                            columns: [
                                                GridItem(.adaptive(minimum: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 150),
                                                        spacing: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                                            ],
                                            spacing: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16
                                        ) {
                                            ForEach(savedResources) { resource in
                                                SavedResourceCard(resource: resource, onRemove: { removedResource in
                                                    if let index = savedResources.firstIndex(where: { $0.id == removedResource.id }) {
                                                        savedResources.remove(at: index)
                                                    }
                                                })
                                            }
                                        }
                                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16)
                                    }
                                }
                            }
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? min(geometry.size.width * 0.8, 1200) : .infinity)
                        }
                        .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 130 : -90)
                    }
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 0)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadProfileImage()
            fetchSavedResources()
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
    let onRemove: (SavedResourceItem) -> Void // Callback for removing resource

    var body: some View {
        VStack(alignment: .leading, spacing: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8) {
            Text(resource.title)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 22 : 16, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Text("Phone: \(resource.phone_number)")
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)

            if let website = resource.website, !website.isEmpty {
                Link("Visit Website", destination: URL(string: website)!)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14))
                    .foregroundColor(.blue)
            }

            Spacer()

            // Heart Button
            HStack {
                Spacer()
                Button(action: toggleSaveResource) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20))
                }
            }
        }
        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
        .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 180 : 120)
        .background(Color.white.opacity(0.2))
        .cornerRadius(16)
        .shadow(radius: 4)
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
