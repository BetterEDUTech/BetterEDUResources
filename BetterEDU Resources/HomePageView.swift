import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct HomePageView: View {
    @State private var profileImage: UIImage? = nil
    @State private var searchText: String = ""
    @State private var resources: [ResourceItem] = []
    @State private var likedResources: Set<String> = [] // Tracks liked resource IDs locally
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header Section with profile picture on the top left
                HStack {
                    NavigationLink(destination: ProfileView()) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 4)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding([.horizontal, .top], 16)

                // Title
                Text("Better Resources")
                    .font(.custom("Lobster1.4", size: 70))
                    .multilineTextAlignment(.center) // Ensures alignment
                    .foregroundColor(Color(hex: "ffffff"))
                    .padding(.top, -50)

                // Subtitle
                Text("Mental Health Resources for Students")
                    .font(.headline)
                    .foregroundColor(.white)

                // Search Bar
                TextField("Search Resources", text: $searchText)
                    .padding()
                    .background(Color(hex: "ffffff"))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)

                // Conditional Display
                ScrollView {
                    if searchText.isEmpty {
                        // Show category buttons when search bar is empty
                        VStack(spacing: 20) {
                            NavigationLink(destination: FinancialServicesView()) {
                                categoryButton(icon: "building.columns.fill", title: "Financial Services")
                            }
                            NavigationLink(destination: EmergencyHotlinesView()) {
                                categoryButton(icon: "phone.arrow.up.right.fill", title: "Emergency Hotlines")
                            }
                            NavigationLink(destination: SelfCareResourcesView()) {
                                categoryButton(icon: "heart.fill", title: "Self-Care Resources")
                            }
                            NavigationLink(destination: AcademicStressView()) {
                                categoryButton(icon: "book.fill", title: "Academic Stress Support")
                            }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        // Show filtered resources when search bar has text
                        VStack(alignment: .leading, spacing: 16) {
                            if filteredResources.isEmpty {
                                Text("No resources found.")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.top, 16)
                            } else {
                                ForEach(filteredResources) { resource in
                                    resourceCard(resource: resource)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 8)

                Spacer()
            }
            .background(
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )            .onAppear {
                loadProfileImage()
                fetchResources()
                fetchLikedResources()
            }
        }
    }

    private func fetchResources() {
        db.collection("resourcesApp")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching resources: \(error.localizedDescription)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    self.resources = documents.compactMap { document in
                        try? document.data(as: ResourceItem.self)
                    }
                }
            }
    }

    // Fetch liked resources from Firebase
    private func fetchLikedResources() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("savedResources")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching liked resources: \(error.localizedDescription)")
                } else {
                    let likedResourceIDs = querySnapshot?.documents.compactMap { $0.documentID } ?? []
                    DispatchQueue.main.async {
                        self.likedResources = Set(likedResourceIDs)
                    }
                }
            }
    }

    private var filteredResources: [ResourceItem] {
        resources.filter { resource in
            searchText.isEmpty || resource.title.lowercased().contains(searchText.lowercased())
        }
    }

    private func categoryButton(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
            Text(title)
                .font(.system(size: 20, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .frame(height: 80)
        .background(Color.white)
        .foregroundColor(Color(hex: "251db4"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private func resourceCard(resource: ResourceItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(resource.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)

                if let phoneNumber = resource.phone_number {
                    Text("Phone: \(phoneNumber)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                if let website = resource.website, let url = URL(string: website) {
                    Link("Website", destination: url)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                } else {
                    Text("No website available")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            Spacer()

            // Heart Button
            Button(action: {
                toggleSaveResource(resource: resource)
            }) {
                Image(systemName: likedResources.contains(resource.id ?? "") ? "heart.fill" : "heart")
                    .foregroundColor(likedResources.contains(resource.id ?? "") ? .red : .gray)
                    .font(.title2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private func toggleSaveResource(resource: ResourceItem) {
        guard let uid = Auth.auth().currentUser?.uid, let resourceID = resource.id else { return }

        let userRef = db.collection("users").document(uid)
        let resourceRef = userRef.collection("savedResources").document(resourceID)

        if likedResources.contains(resourceID) {
            // If the resource is already saved, remove it
            resourceRef.delete { error in
                if let error = error {
                    print("Error removing resource: \(error)")
                } else {
                    DispatchQueue.main.async {
                        likedResources.remove(resourceID)
                    }
                }
            }
        } else {
            // If the resource is not saved, add it
            let resourceData: [String: Any] = [
                "id": resourceID,
                "title": resource.title,
                "phone_number": resource.phone_number ?? "",
                "website": resource.website ?? "",
                "resourceType": resource.resourceType ?? ""
            ]
            resourceRef.setData(resourceData) { error in
                if let error = error {
                    print("Error saving resource: \(error)")
                } else {
                    DispatchQueue.main.async {
                        likedResources.insert(resourceID)
                    }
                }
            }
        }
    }

    private func loadProfileImage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists,
               let profileImageURLString = document.data()?["profileImageURL"] as? String,
               let url = URL(string: profileImageURLString) {
                fetchImage(from: url)
            }
        }
    }

    private func fetchImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = uiImage
                }
            }
        }.resume()
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}


// Custom extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
