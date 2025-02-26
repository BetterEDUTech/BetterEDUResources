import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var tabViewModel: TabViewModel
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
    @State private var isLocationDropdownOpen = false
    @State private var isSchoolDropdownOpen = false
    @State private var navigateToSavedResources = false
    
    private let locations = ["California", "Arizona"]
    private let schoolsByState = [
        "California": ["UC Berkeley", "UCLA", "UC San Diego", "Stanford University", "USC"],
        "Arizona": ["Arizona State University", "University of Arizona", "Northern Arizona University"]
    ]
    
    private var availableSchools: [String] {
        schoolsByState[selectedLocation] ?? []
    }

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private var isIPad: Bool {
        sizeClass == .regular
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background Image
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)

                    ScrollView {
                        VStack(spacing: 20) {
                            // Dismiss Button
                            HStack {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: isIPad ? 32 : 24))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, isIPad ? 50 : 110)

                            // Profile Image
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

                            // User Name
                            HStack {
                                if isEditingName {
                                    TextField("Enter name", text: $tempUserName)
                                        .font(.system(size: isIPad ? 28 : 22, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .background(Color.black.opacity(0.4))
                                        .cornerRadius(8)
                                        .onSubmit {
                                            if !tempUserName.isEmpty {
                                                userName = tempUserName
                                                updateUserData(field: "name", value: tempUserName)
                                            }
                                            isEditingName = false
                                        }
                                } else {
                                    Text(userName)
                                        .font(.system(size: isIPad ? 28 : 22, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                Button(action: { 
                                    if !isEditingName {
                                        tempUserName = userName
                                        isEditingName = true
                                    } else {
                                        if !tempUserName.isEmpty {
                                            userName = tempUserName
                                            updateUserData(field: "name", value: tempUserName)
                                        }
                                        isEditingName = false
                                    }
                                }) {
                                    Image(systemName: isEditingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: isIPad ? 24 : 20))
                                }
                            }
                            .frame(maxWidth: isIPad ? 700 : 350)
                            .padding(.horizontal)

                            // Info Cards and Actions
                            VStack(spacing: 12) {
                                infoCard(title: "Email", value: email, icon: "envelope.fill")
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    // Location Dropdown
                                    Button(action: { isLocationDropdownOpen.toggle() }) {
                                        infoCard(title: "Location", value: selectedLocation, icon: "location.fill")
                                    }
                                    .frame(width: isIPad ? 700 : 350)
                                    
                                    if isLocationDropdownOpen {
                                        VStack(alignment: .leading, spacing: 8) {
                                            ForEach(locations, id: \.self) { location in
                                                Button(action: {
                                                    selectedLocation = location
                                                    // Reset school selection when location changes
                                                    selectedSchool = "[School]"
                                                    isLocationDropdownOpen = false
                                                    // Update in Firestore
                                                    updateUserData(field: "location", value: location)
                                                }) {
                                                    Text(location)
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 8)
                                                        .padding(.horizontal, 16)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                .background(selectedLocation == location ? Color.black.opacity(0.6) : Color.clear)
                                            }
                                        }
                                        .background(Color.black.opacity(0.4))
                                        .cornerRadius(12)
                                        .padding(.top, 4)
                                    }

                                    // School Dropdown
                                    Button(action: { isSchoolDropdownOpen.toggle() }) {
                                        infoCard(title: "School", value: selectedSchool, icon: "book.fill")
                                    }
                                    .frame(width: isIPad ? 700 : 350)
                                    .disabled(selectedLocation == "[Location]")
                                    
                                    if isSchoolDropdownOpen && selectedLocation != "[Location]" {
                                        VStack(alignment: .leading, spacing: 8) {
                                            ForEach(availableSchools, id: \.self) { school in
                                                Button(action: {
                                                    selectedSchool = school
                                                    isSchoolDropdownOpen = false
                                                    // Update in Firestore
                                                    updateUserData(field: "school", value: school)
                                                }) {
                                                    Text(school)
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 8)
                                                        .padding(.horizontal, 16)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                .background(selectedSchool == school ? Color.black.opacity(0.6) : Color.clear)
                                            }
                                        }
                                        .background(Color.black.opacity(0.4))
                                        .cornerRadius(12)
                                        .padding(.top, 4)
                                    }
                                }
                                .animation(.easeInOut, value: isLocationDropdownOpen)
                                .animation(.easeInOut, value: isSchoolDropdownOpen)

                                Button(action: {
                                    dismiss()
                                    tabViewModel.selectedTab = 2  // Switch to Saved tab
                                }) {
                                    actionButton(icon: "heart.fill", text: "Saved Resources", color: .purple)
                                }
                                
                                Button(action: {
                                    dismiss()
                                    authViewModel.signOut()
                                }) {
                                    actionButton(icon: "arrow.right.square.fill", text: "Log Out", color: .purple)
                                }
                                
                                Button(action: {
                                    showDeleteConfirmation = true
                                }) {
                                    actionButton(icon: "trash", text: "Delete Account", color: .red)
                                }
                            }
                            .frame(maxWidth: isIPad ? 700 : 350)
                            .padding(.horizontal, isIPad ? 40 : 16)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isIPad ? 150 : 30)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
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
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.4))
        .cornerRadius(12)
    }

    private func actionButton(icon: String, text: String, color: Color = .white) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: isIPad ? 24 : 20))
            Text(text)
                .font(.system(size: isIPad ? 20 : 17, weight: .semibold))
            Spacer()
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Group {
                if text == "Log Out" {
                    Color.purple
                } else if text == "Delete Account" {
                    Color.red
                } else {
                    Color.black.opacity(0.4)
                }
            }
        )
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
