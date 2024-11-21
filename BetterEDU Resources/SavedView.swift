import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct SavedView: View {
    @State private var savedResources: [SavedResourceItem] = [] // Dynamically fetched saved resources
    @State private var isShowingHomePage = false
    @State private var isShowingResources = false
    @State private var isShowingFeedback = false
    @State private var profileImage: UIImage? = nil // State to store the profile image

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(hex: "251db4").ignoresSafeArea()

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
                                    .padding(.leading)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .padding(.leading)
                            }
                        }
                        Spacer()
                    }

                    // Title
                    Text("My Saved Resources")
                        .font(.custom("Impact", size: 28))
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
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(savedResources) { resource in
                                    SavedResourceCard(resource: resource)
                                }
                            }
                            .padding(.horizontal)
                        }
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
                            if !isShowingResources {
                                isShowingResources = true
                            }
                        }
                        .fullScreenCover(isPresented: $isShowingResources) {
                            ResourcesAppView()
                        }
                        Spacer()
                        navBarButton(icon: "heart.fill", label: "Saved") {
                            // Do nothing if already on the Saved tab
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

    var body: some View {
        VStack {
            Text(resource.title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Text("Phone: \(resource.phone_number)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            if let website = resource.website, !website.isEmpty {
                Link("Visit Website", destination: URL(string: website)!)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

// Preview for SavedView
struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        SavedView()
    }
}
