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

                VStack(spacing: 20) {
                    // Header with profile picture on the left
                    HStack {
                        NavigationLink(destination: ProfileView()) {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 4)
                                    .padding(.leading, 30)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .padding(.leading, 30)
                            }
                        }
                        Spacer()
                    }

                    // Title
                    Text("My Saved Resources")
                        .font(.custom("Impact", size: 40))
                        .foregroundColor(.white)
                        .padding()

                    // Scrollable grid of saved resources
                    if savedResources.isEmpty {
                        Text("No saved resources yet.")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(
                                columns: [GridItem(.adaptive(minimum: 150), spacing: 16)],
                                spacing: 16
                            ) {
                                ForEach(savedResources) { resource in
                                    SavedResourceCard(resource: resource, onRemove: { removedResource in
                                        // Remove the resource from the savedResources array
                                        if let index = savedResources.firstIndex(where: { $0.id == removedResource.id }) {
                                            savedResources.remove(at: index)
                                        }
                                    })
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
            }
            .onAppear(perform: {
                loadProfileImage()
                fetchSavedResources()
            })
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

            Spacer()

            // Heart Button
            HStack {
                Spacer()
                Button(action: toggleSaveResource) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                        .font(.title3)
                }
            }
        }
        .padding()
        .frame(width: 150, height: 120) // Maintain uniform size
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
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
