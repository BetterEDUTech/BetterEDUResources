import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct HomePageView: View {
    @State private var profileImage: UIImage? = nil
    @State private var searchText: String = ""
    @State private var resources: [ResourceItem] = []
    @State private var likedResources: Set<String> = [] // Tracks liked resource IDs locally
    @State private var hasScrolled = false
    @State private var userState: String = "ALL"        // User's selected state
    @EnvironmentObject var tabViewModel: TabViewModel
    private let db = Firestore.firestore()

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

    // Scroll Arrow View
    private var scrollArrow: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(Color.black.opacity(0.3))
            .clipShape(Circle())
            .opacity(hasScrolled ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: hasScrolled)
            .modifier(BounceAnimation())
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    VStack(spacing: 0) {  // Changed spacing to 0 for manual control
                        // Header Section
                        VStack(spacing: 16) {
                            // Header Section with profile picture
                            HStack {
                                NavigationLink(destination: ProfileView().navigationBarHidden(true)) {
                                    if let image = profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 40, 
                                                   height: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 40)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 4)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 40, 
                                                   height: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 40)
                                            .foregroundColor(.white)
                                    }
                                }
                                Spacer()
                            }
                            .padding([.horizontal, .top], UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)

                            // Title
                            Text("BetterResources")
                                .font(.custom("tan-nimbus", size: UIDevice.current.userInterfaceIdiom == .pad ? 55 : 39))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.top, -10)

                            // Subtitle
                            VStack(spacing: 0) {
                                Text("Mental Health Resources")
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 24))
                                    .foregroundColor(.white)
                                Text("for Students")
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 24))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Visual Divider
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
                        
                        // Content Section
                        VStack(spacing: 24) {  // Increased spacing between elements
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
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                            .padding(.top, 20)  // Added top padding after divider

                            // Content Area
                            ScrollView {
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.frame(in: .named("scroll")).minY) { value in
                                        if value < -10 && !hasScrolled {
                                            hasScrolled = true
                                        }
                                    }
                                }
                                .frame(height: 0)

                                if searchText.isEmpty {
                                    // Category Grid
                                    LazyVGrid(columns: gridColumns, spacing: 20) {
                                        Button(action: {
                                            tabViewModel.selectedTab = 3  // Switch to Student Discounts tab
                                        }) {
                                            categoryButton(icon: "tag.fill", title: "Student Discounts")
                                        }
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
                                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                                    .padding(.top, 12)
                                    .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 90 : 80)
                                } else {
                                    // Search Results
                                    LazyVGrid(columns: gridColumns, spacing: 20) {
                                        if filteredResources.isEmpty {
                                            Text("No resources found.")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding(.top, 16)
                                                .gridCellColumns(gridColumns.count)
                                        } else {
                                            ForEach(filteredResources) { resource in
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

                                                    Button(action: {
                                                        toggleSaveResource(resource: resource)
                                                    }) {
                                                        Image(systemName: likedResources.contains(resource.id ?? "") ? "heart.fill" : "heart")
                                                            .foregroundColor(likedResources.contains(resource.id ?? "") ? .red : .gray)
                                                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20))
                                                    }
                                                }
                                                .padding(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
                                                .frame(maxWidth: .infinity)
                                                .background(Color.black.opacity(0.4))
                                                .cornerRadius(12)
                                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                                    .padding(.top, 12)
                                    .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 90 : 80)
                                }
                            }
                            .coordinateSpace(name: "scroll")
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

                    // Scroll Arrow Overlay
                    VStack {
                        Spacer()
                        scrollArrow
                            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 120 : 100)
                    }
                }
                .onAppear {
                    loadProfileImage()
                    loadUserData()
                    fetchResources()
                    fetchLikedResources()
                    hasScrolled = false
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
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
            let matchesSearch = searchText.isEmpty || resource.title.lowercased().contains(searchText.lowercased())
            let matchesState = resource.state == "ALL" || resource.state == userState
            return matchesSearch && matchesState
        }
    }

    private func categoryButton(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 24))
            Text(title)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 80)
        .background(Color.white)
        .foregroundColor(Color(hex: "#5a0ef6"))
        .cornerRadius(12)
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

// Bounce Animation Modifier
struct BounceAnimation: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? -10 : 0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

