import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct SavedView: View {
    @State private var savedResources: [SavedResourceItem] = []
    @StateObject private var imageLoader = ProfileImageLoader.shared
    @State private var searchText: String = ""
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header with profile icon
                HStack {
                    NavigationLink(destination: ProfileView().navigationBarHidden(true)) {
                        if let image = imageLoader.profileImage {
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
                            .tint(.blue)
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
            if let uid = Auth.auth().currentUser?.uid {
                ProfileImageLoader.shared.loadProfileImage(forUID: uid)
            }
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
    @State private var isLiked: Bool = true  // Should start as true since it's a saved resource
    @EnvironmentObject var tabViewModel: TabViewModel // Add TabViewModel environment object
    private let db = Firestore.firestore()
    let onRemove: (SavedResourceItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(resource.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            if !resource.phone_number.isEmpty {
                // Make phone number clickable to open phone app
                let formattedPhone = resource.phone_number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                if let phoneURL = URL(string: "tel:\(formattedPhone)") {
                    Link(destination: phoneURL) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                            Text(resource.phone_number)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)
                                .underline()
                        }
                    }
                } else {
                    Text("Phone: \(resource.phone_number)")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }

            // Remove button and website separated with some space
            Spacer()
                .frame(height: 8)
            
            HStack {
                // Website Button
                if let website = resource.website, !website.isEmpty, let url = URL(string: website) {
                    Link(destination: url) {
                        HStack {
                            Text("Visit Website")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 14, weight: .semibold))
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 14 : 12))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#5a0ef6"), Color(hex: "#7849fd")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                } else if resource.phone_number.isEmpty {
                    // Only show "Website unavailable" if there's no phone number either
                    Text("Website unavailable")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                } else {
                    // If there's a phone number but no website, don't show anything here
                    Spacer()
                }
                
                Spacer()
                    .frame(width: 16)
                
                // Save/Unsave Button
                Button(action: toggleSaveResource) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                        .font(.system(size: 20))
                }
                .frame(width: 40)
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
                        // Trigger a refresh when a resource is unsaved
                        tabViewModel.refreshResourcesOnSave()
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
                        // Trigger a refresh when a resource is saved
                        tabViewModel.refreshResourcesOnSave()
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
