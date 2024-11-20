import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct HomePageView: View {
    @State private var selectedTab = 0
    @State private var isShowingResources = false
    @State private var isShowingSaved = false
    @State private var isShowingFeedback = false
    @State private var profileImage: UIImage? = nil // State to store the profile image
    @State private var searchText: String = ""      // Search bar text
    @State private var resources: [ResourceItem] = [] // Array to store resources
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Section with profile picture on the top left
                HStack {
                    // Navigation link for the profile icon with image
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
                                .padding(.leading)
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                
                Text("BetterEDU Resources")
                    .font(.custom("Impact", size: 40))
                    .foregroundColor(Color(hex: "98b6f8")) // Custom color from palette
                    .aspectRatio(contentMode: .fit)
                    .padding(.top)
                
                Text("Mental Health Resources for Students")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Search Bar
                TextField("Search Resources", text: $searchText)
                    .padding()
                    .background(Color(hex: "98b6f8"))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                // Conditional Display
                ScrollView {
                    if searchText.isEmpty {
                        // Show category buttons when search bar is empty
                        VStack(alignment: .leading, spacing: 20) {
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
                        .padding(.horizontal)
                    } else {
                        // Show filtered resources when search bar has text
                        VStack(alignment: .leading, spacing: 16) { // Uniform spacing between cards
                            if filteredResources.isEmpty {
                                Text("No resources found.")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.top)
                            } else {
                                ForEach(filteredResources) { resource in
                                    resourceCard(resource: resource)
                                }
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
                        // Do nothing if already on Home
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
            .background(Color(hex: "251db4").ignoresSafeArea()) // Background color from the mockup
            .onAppear {
                loadProfileImage()
                fetchResources()
            }
        }
    }
    
    // Fetch resources from Firestore
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
    
    // Filtered resources based on search query
    private var filteredResources: [ResourceItem] {
        resources.filter { resource in
            searchText.isEmpty || resource.title.lowercased().contains(searchText.lowercased())
        }
    }
    
    // Helper for category buttons
    private func categoryButton(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title).bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .foregroundColor(Color(hex: "251db4"))
        .cornerRadius(10)
    }

    // Resource Card View
    private func resourceCard(resource: ResourceItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(resource.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2) // Prevent excessive height due to long titles
            
            Text("Phone: \(resource.phone_number)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            if let website = resource.website {
                Link("Website", destination: URL(string: website)!)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120) // Ensures uniform height
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .shadow(radius: 4) // Adds subtle shadow for better design
    }
    
    // Load Profile Image
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
    
    // Helper function for bottom navigation bar buttons
    private func navBarButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.footnote)
            }
            .foregroundColor(.white)
        }
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
