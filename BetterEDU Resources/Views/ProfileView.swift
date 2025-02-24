import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var userName: String = "[Name]"
    @State private var email: String = "[Email]"
    @State private var profileImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var selectedLocation: String = "[Location]"
    @State private var selectedSchool: String = "[School]"
    @State private var showDeleteConfirmation = false
    @State private var isEditingName = false
    @State private var tempUserName = ""
    @State private var showLocationPicker = false
    @State private var showSchoolPicker = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Device-specific sizing
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Available options for dropdowns
    private let locations = ["Arizona", "California"]
    private let schools = [
        "Arizona State University",
        "University of Arizona",
        "Northern Arizona University",
        "UCLA",
        "UC Berkeley",
        "Stanford University",
        "University of Southern California",
        "San Diego State University"
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: isIPad ? 24 : 16) {
                            // Dismiss Button
                            HStack {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: isIPad ? 32 : 24))
                                        .foregroundColor(.white)
                                }
                                .padding(.leading, isIPad ? 24 : 16)
                                .padding(.top, isIPad ? 16 : 12)
                                Spacer()
                            }
                            
                            // Profile Image Section
                            VStack(alignment: .leading, spacing: isIPad ? 16 : 12) {
                                Button(action: { isShowingImagePicker = true }) {
                                    if let image = profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: isIPad ? 160 : 100, height: isIPad ? 160 : 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    } else {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: isIPad ? 160 : 100, height: isIPad ? 160 : 100)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: isIPad ? 40 : 30))
                                            )
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: isIPad ? 40 : 30, height: isIPad ? 40 : 30)
                                        .overlay(
                                            Image(systemName: "pencil")
                                                .foregroundColor(.white)
                                                .font(.system(size: isIPad ? 20 : 15))
                                        )
                                        .offset(x: isIPad ? 55 : 35, y: isIPad ? 55 : 35)
                                )
                                
                                // Name Section
                                if isEditingName {
                                    HStack(spacing: 8) {
                                        TextField("Enter name", text: $tempUserName)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .font(.system(size: isIPad ? 22 : 17))
                                            .frame(width: min(geometry.size.width * 0.6, 200))
                                        
                                        Button("Save") {
                                            updateUserName(tempUserName)
                                            isEditingName = false
                                        }
                                        .foregroundColor(.blue)
                                        
                                        Button("Cancel") {
                                            isEditingName = false
                                            tempUserName = userName
                                        }
                                        .foregroundColor(.red)
                                    }
                                } else {
                                    HStack {
                                        Text(userName)
                                            .font(.system(size: isIPad ? 28 : 22, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Button(action: {
                                            tempUserName = userName
                                            isEditingName = true
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: isIPad ? 24 : 20))
                                        }
                                    }
                                }
                            }
                            .padding(.top, isIPad ? 20 : 12)
                            .padding(.leading, isIPad ? 24 : 20)
                            
                            // Info Cards
                            VStack(alignment: .leading, spacing: isIPad ? 16 : 12) {
                                // Email Card
                                infoCard(title: "Email", value: email, icon: "envelope.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, isIPad ? 0 : 16)
                                
                                // Location Card
                                Button(action: { showLocationPicker = true }) {
                                    infoCard(title: "Location", value: selectedLocation, icon: "location.fill")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, isIPad ? 0 : 16)
                                .confirmationDialog("Select Location", 
                                    isPresented: $showLocationPicker,
                                    titleVisibility: .visible) {
                                    ForEach(locations, id: \.self) { location in
                                        Button(location) {
                                            selectedLocation = location
                                            updateUserData(field: "location", value: location)
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
                                
                                // School Card
                                Button(action: { showSchoolPicker = true }) {
                                    infoCard(title: "School", value: selectedSchool, icon: "book.fill")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, isIPad ? 0 : 16)
                                .confirmationDialog("Select School", 
                                    isPresented: $showSchoolPicker,
                                    titleVisibility: .visible) {
                                    ForEach(schools, id: \.self) { school in
                                        Button(school) {
                                            selectedSchool = school
                                            updateUserData(field: "school", value: school)
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
                                
                                // Saved Resources Button
                                NavigationLink(destination: SavedView().navigationBarHidden(true)) {
                                    HStack {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: isIPad ? 24 : 20))
                                        Text("Saved Resources")
                                            .font(.system(size: isIPad ? 20 : 17, weight: .semibold))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: isIPad ? 20 : 16))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, isIPad ? 20 : 12)
                                    .padding(.vertical, isIPad ? 16 : 10)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, isIPad ? 0 : 16)
                                }
                                .padding(.top, isIPad ? 16 : 12)
                                
                                // Log Out Button
                                Button(action: { authViewModel.signOut() }) {
                                    HStack {
                                        Image(systemName: "arrow.right.square.fill")
                                        Text("Log Out")
                                            .font(.system(size: isIPad ? 20 : 17, weight: .semibold))
                                        Spacer()
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, isIPad ? 20 : 12)
                                    .padding(.vertical, isIPad ? 16 : 10)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(12)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, isIPad ? 0 : 16)
                                }
                                .padding(.top, isIPad ? 16 : 12)
                                
                                // Delete Account Button
                                Button(action: { showDeleteConfirmation = true }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Delete Account")
                                            .font(.system(size: isIPad ? 20 : 17, weight: .semibold))
                                        Spacer()
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, isIPad ? 20 : 12)
                                    .padding(.vertical, isIPad ? 16 : 10)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(12)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, isIPad ? 0 : 16)
                                }
                            }
                            .padding(.horizontal, isIPad ? 24 : 8)
                            
                            Spacer(minLength: isIPad ? 30 : 20)
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear { loadUserData() }
        .sheet(isPresented: $isShowingImagePicker) {
            PhotoPicker(selectedImage: $profileImage, onImagePicked: saveProfileImage)
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { authViewModel.deleteAccount() }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
    }
    
    private func infoCard(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: isIPad ? 24 : 20))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: isIPad ? 16 : 14))
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.system(size: isIPad ? 20 : 17))
            }
            Spacer()
            if title != "Email" {
                Image(systemName: "chevron.right")
                    .font(.system(size: isIPad ? 20 : 16))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, isIPad ? 20 : 12)
        .padding(.vertical, isIPad ? 16 : 10)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
    
    // MARK: - Data Management Functions
    private func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No user ID available")
            return
        }
        
        print("Loading user data for UID: \(uid)")
        
        // Listen for real-time updates
        db.collection("users").document(uid)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Error fetching document: \(error.localizedDescription)")
                    return
                }
                
                guard let document = documentSnapshot, document.exists,
                      let data = document.data() else {
                    print("No document data found")
                    return
                }
                
                print("Received user data update")
                
                DispatchQueue.main.async {
                    self.userName = data["name"] as? String ?? "[Name]"
                    self.email = data["email"] as? String ?? "[Email]"
                    self.selectedLocation = data["location"] as? String ?? "[Location]"
                    self.selectedSchool = data["school"] as? String ?? "[School]"
                    
                    if let profileImageURLString = data["profileImageURL"] as? String {
                        print("Found profile image URL: \(profileImageURLString)")
                        if let url = URL(string: profileImageURLString) {
                            self.loadImage(from: url)
                        }
                    } else {
                        print("No profile image URL found in user data")
                    }
                }
            }
    }
    
    private func loadImage(from url: URL) {
        print("Loading image from URL: \(url.absoluteString)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("Invalid response status code: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            guard let image = UIImage(data: data) else {
                print("Could not create image from data")
                return
            }
            
            print("Successfully loaded profile image")
            DispatchQueue.main.async {
                self.profileImage = image
            }
        }
        task.resume()
    }
    
    private func saveProfileImage(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Error: Failed to get user ID or convert image to data")
            return
        }
        
        print("Starting profile image upload for user: \(uid)")
        
        // Show the image immediately in UI
        DispatchQueue.main.async {
            self.profileImage = image
        }
        
        // Create a reference to Firebase Storage
        let storageRef = storage.reference()
        let imageRef = storageRef.child("profile_images/\(uid).jpg")
        
        // Create metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the new image data directly without trying to delete first
        print("Uploading image data...")
        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            print("Image uploaded successfully, getting download URL...")
            // Get the download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                
                guard let downloadURL = url else {
                    print("Error: Could not get download URL")
                    return
                }
                
                print("Got download URL: \(downloadURL.absoluteString)")
                
                // Update Firestore with the new URL
                self.db.collection("users").document(uid).updateData([
                    "profileImageURL": downloadURL.absoluteString,
                    "lastUpdated": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("Error updating profile image URL in Firestore: \(error.localizedDescription)")
                    } else {
                        print("Profile image URL successfully updated in Firestore")
                        // Force a reload of user data to verify the update
                        DispatchQueue.main.async {
                            self.loadUserData()
                        }
                    }
                }
            }
        }
    }
    
    private func updateUserName(_ newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).updateData([
            "name": newName
        ]) { error in
            if let error = error {
                print("Error updating name: \(error.localizedDescription)")
            } else {
                self.userName = newName
            }
        }
    }
    
    private func updateUserData(field: String, value: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).updateData([
            field: value
        ]) { error in
            if let error = error {
                print("Error updating \(field): \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - PhotoPicker
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    ProfileView()
}
