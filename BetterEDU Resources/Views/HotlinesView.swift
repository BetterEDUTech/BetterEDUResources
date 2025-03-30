import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct HotlinesView: View {
    @State private var searchText = ""
    @State private var hotlineResources: [ResourceItem] = [] // Dynamic resources fetched from Firestore
    @State private var userState: String = "ALL"        // User's selected state
    @Environment(\.presentationMode) var presentationMode // For custom back navigation
    @EnvironmentObject var authViewModel: AuthViewModel
    private let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Custom header with back button
            HStack {
                Button(action: {
                    // Go back to previous screen
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Title
            Text("Hotlines")
                .font(.custom("Impact", size: 35))
                .foregroundColor(Color(hex: "#FFFFFF"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 6)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search Hotlines", text: $searchText)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 16)

            // Hotline List
            ScrollView {
                LazyVStack(spacing: 16) {
                    if filteredHotlines.isEmpty {
                        Text("No hotlines found.")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(filteredHotlines) { hotline in
                            HotlineCard(hotline: hotline)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
        .padding(.bottom)
        .background(
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarHidden(true) // Hide the navigation bar
        .onAppear {
            loadUserData()
            fetchHotlineResources()
        }
    }

    // Fetch resources that have phone numbers from Firestore
    private func fetchHotlineResources() {
        db.collection("resourcesApp")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching hotline resources: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    
                    // Filter resources to include only those with phone numbers
                    self.hotlineResources = documents.compactMap { document in
                        if let resource = try? document.data(as: ResourceItem.self),
                           let phoneNumber = resource.phone_number,
                           !phoneNumber.isEmpty {
                            return resource
                        }
                        return nil
                    }
                }
            }
    }

    // Filter hotlines based on search text and state
    private var filteredHotlines: [ResourceItem] {
        hotlineResources.filter { hotline in
            let matchesSearch = searchText.isEmpty || hotline.title.lowercased().contains(searchText.lowercased())
            let matchesState = hotline.state == "ALL" || hotline.state == userState
            return matchesSearch && matchesState
        }
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

// Custom view for displaying hotlines
struct HotlineCard: View {
    let hotline: ResourceItem
    @State private var isLiked: Bool = false
    @State private var showGuestAlert = false
    @EnvironmentObject var authViewModel: AuthViewModel
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Hotline Title
            Text(hotline.title)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            // Phone Number with Call Button
            if let phoneNumber = hotline.phone_number, !phoneNumber.isEmpty {
                let formattedPhone = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                
                if let phoneURL = URL(string: "tel:\(formattedPhone)") {
                    VStack(spacing: 12) {
                        // Display the phone number prominently
                        Text(phoneNumber)
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Call Button
                        Link(destination: phoneURL) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 22 : 18))
                                Text("Call Now")
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "#5a0ef6"), Color(hex: "#7849fd")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                }
            }
            
            // Bottom row with website (if available) and save button
            HStack {
                if let website = hotline.website, !website.isEmpty, let url = URL(string: website) {
                    // Website Button
                    Link(destination: url) {
                        HStack {
                            Text("Visit Website")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 14, weight: .medium))
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 14 : 12))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#5a0ef6"), Color(hex: "#7849fd")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Spacer()
                
                // Save Button
                Button(action: handleSaveResource) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .white)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20))
                }
                .padding(8)
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
            }
        }
        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#333333"), Color(hex: "#222222")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
        .onAppear(perform: checkIfResourceIsSaved)
        .alert("Sign In Required", isPresented: $showGuestAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign In") {
                // Sign out the guest user and this will trigger navigation to LoginView
                authViewModel.signOut()
            }
        } message: {
            Text("You need to create an account or sign in to save resources.")
        }
    }
    
    private func handleSaveResource() {
        if Auth.auth().currentUser?.isAnonymous == true {
            showGuestAlert = true
        } else {
            toggleSaveResource()
        }
    }

    // Check if the resource is saved
    private func checkIfResourceIsSaved() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(uid).collection("savedResources").document(hotline.id ?? "")

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
        let resourceRef = userRef.collection("savedResources").document(hotline.id ?? "")

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
                "id": hotline.id ?? "",
                "title": hotline.title,
                "phone_number": hotline.phone_number ?? "",
                "website": hotline.website ?? "",
                "resourceType": hotline.resourceType ?? "",
                "state": hotline.state ?? ""
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

struct HotlinesView_Previews: PreviewProvider {
    static var previews: some View {
        HotlinesView()
    }
} 