import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var userName: String = "[Name]"
    @State private var email: String = "[Email]"
    @State private var profileImage: UIImage? = nil
    @State private var profileImageURL: URL?
    @State private var isShowingImagePicker = false
    @State private var errorMessage: String?
    @State private var isShowingSavedResources = false
    @State private var selectedLocation: String = "[Location]"
    @State private var isLocationDropdownExpanded: Bool = false
    @State private var selectedSchool: String = "[School]"
    @State private var isSchoolDropdownExpanded: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var isEditingName: Bool = false
    @State private var tempUserName: String = ""

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 40 : -20) {
                            // Add top safe area padding
                            Color.clear.frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 95 : -50)
                            
                            
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16)
                            
                            // Profile Image Section
                            VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8) {
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 180 : 100,
                                               height: UIDevice.current.userInterfaceIdiom == .pad ? 180 : 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 4)
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 180 : 100,
                                               height: UIDevice.current.userInterfaceIdiom == .pad ? 180 : 100)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30))
                                        )
                                        .shadow(radius: 4)
                                }
                                
                                Text("Change Profile Picture")
                                    .foregroundColor(.white)
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 22 : 16))
                                    .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8)
                                    .onTapGesture {
                                        isShowingImagePicker = true
                                    }
                                
                                HStack(spacing: 10) {
                                    Text(userName)
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 36 : 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Button(action: {
                                        tempUserName = userName
                                        isEditingName = true
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20))
                                    }
                                }
                                
                                if isEditingName {
                                    HStack {
                                        TextField("Enter new name", text: $tempUserName)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .foregroundColor(.black)
                                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18))
                                            .padding(.horizontal)
                                        
                                        Button(action: {
                                            updateUserName(tempUserName)
                                            isEditingName = false
                                        }) {
                                            Text("Save")
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(Color.blue)
                                                .cornerRadius(8)
                                        }
                                        
                                        Button(action: {
                                            isEditingName = false
                                            tempUserName = userName
                                        }) {
                                            Text("Cancel")
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(Color.red)
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16)
                            
                            // Form Fields Container
                            VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 20) {
                                // Form Fields Content
                                VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 20) {
                                    formSection(title: "Email") {
                                    TextField("Email", text: .constant(email))
                                        .foregroundColor(.white)
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16))
                                        .padding()
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(12)
                                        .disabled(true)
                                }
                                
                                    formSection(title: "Location") {
                                        locationButton
                                        if isLocationDropdownExpanded {
                                            locationDropdown
                                        }
                                    }
                                    
                                    formSection(title: "School") {
                                        schoolButton
                                        if isSchoolDropdownExpanded {
                                            schoolDropdown
                                        }
                                    }
                                }
                            
                            // Action Buttons
                                VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16) {
                                NavigationLink(destination: SavedView().navigationBarHidden(true)) {
                                    profileRow(icon: "heart.fill", text: "Saved Resources")
                                }
                                
                                    Button(action: { authViewModel.signOut() }) {
                                    HStack {
                                        Image(systemName: "arrow.right.square.fill")
                                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20))
                                        Text("Log Out")
                                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(12)
                                }
                                
                                    Button(action: { showDeleteConfirmation = true }) {
                                    HStack {
                                        Image(systemName: "trash")
                                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20))
                                        Text("Delete Account")
                                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(12)
                                }
                            }
                            }
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? min(geometry.size.width * 0.5, 600) : .infinity)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 0 : 16)
                        }
                        .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 0)
                    }
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 0)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear { loadUserData() }
        .sheet(isPresented: $isShowingImagePicker) {
            PhotoPicker(selectedImage: $profileImage, onImagePicked: saveProfileImage)
        }
        .alert("Confirm Account Deletion", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                authViewModel.deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
    }

    private var locationButton: some View {
        Button(action: {
            withAnimation { isLocationDropdownExpanded.toggle() }
        }) {
            HStack {
                Text(selectedLocation)
                    .foregroundColor(.white)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16))
                Spacer()
                Image(systemName: isLocationDropdownExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.white)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14))
            }
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
        }
    }

    private var locationDropdown: some View {
        VStack(spacing: 0) {
            locationOption("Arizona")
            Divider().background(Color.white)
            locationOption("California")
        }
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }

    private var schoolButton: some View {
        Button(action: {
            withAnimation { isSchoolDropdownExpanded.toggle() }
        }) {
            HStack {
                Text(selectedSchool)
                    .foregroundColor(.white)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16))
                Spacer()
                Image(systemName: isSchoolDropdownExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.white)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14))
            }
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
        }
    }

    private var schoolDropdown: some View {
        VStack(spacing: 0) {
            ForEach(filteredSchools, id: \.self) { school in
                schoolOption(school)
            }
        }
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }

    private func formSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18, weight: .bold))
            content()
        }
    }

    private func locationOption(_ location: String) -> some View {
        Button(action: {
            withAnimation {
                isLocationDropdownExpanded = false
            }
            updateLocation(location)
        }) {
            Text(location)
                .foregroundColor(.white)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16))
                .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
    }

    private func schoolOption(_ school: String) -> some View {
        Button(action: {
            withAnimation {
                isSchoolDropdownExpanded = false
            }
            updateSchool(school)
        }) {
            Text(school)
                .foregroundColor(.white)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16))
                .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
    }

    private func profileRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20))
            Text(text)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 22 : 18, weight: .bold))
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16)
        .padding(.horizontal)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }

    private var filteredSchools: [String] {
        let arizonaSchools = ["Arizona State University", "University of Arizona", "Northern Arizona University"]
        let californiaSchools = [
            "Stanford University", "California Institute of Technology", "University of California, Berkeley",
            "University of Southern California", "University of California, Los Angeles"
        ]

        switch selectedLocation {
        case "Arizona":
            return arizonaSchools
        case "California":
            return californiaSchools
        default:
            return []
        }
    }

    private func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                self.errorMessage = "Error loading user data: \(error.localizedDescription)"
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["name"] as? String ?? "[Name]"
                self.email = data?["email"] as? String ?? "[Email]"
                self.selectedLocation = data?["location"] as? String ?? "[Location]"
                self.selectedSchool = data?["school"] as? String ?? "[School]"
                if let profileImageURLString = data?["profileImageURL"] as? String,
                   let url = URL(string: profileImageURLString) {
                    self.profileImageURL = url
                    loadImage(from: url)
                }
            }
        }
    }

    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = uiImage
                }
            }
        }
        task.resume()
    }

    private func saveProfileImage(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = storage.reference().child("profile_images/\(uid).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                self.errorMessage = "Error uploading profile image: \(error.localizedDescription)"
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    self.errorMessage = "Error retrieving profile image URL: \(error.localizedDescription)"
                } else if let url = url {
                    self.profileImageURL = url
                    self.updateProfileImageURL(uid: uid, url: url)
                }
            }
        }
    }

    private func updateProfileImageURL(uid: String, url: URL) {
        db.collection("users").document(uid).updateData(["profileImageURL": url.absoluteString]) { error in
            if let error = error {
                self.errorMessage = "Error saving profile image URL: \(error.localizedDescription)"
            }
        }
    }

    private func updateLocation(_ location: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).updateData(["location": location]) { error in
            if let error = error {
                self.errorMessage = "Error updating location: \(error.localizedDescription)"
            } else {
                self.selectedLocation = location
                self.selectedSchool = "[School]"
            }
        }
    }

    private func updateSchool(_ school: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).updateData(["school": school]) { error in
            if let error = error {
                self.errorMessage = "Error updating school: \(error.localizedDescription)"
            } else {
                self.selectedSchool = school
            }
        }
    }

    private func updateUserName(_ newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).updateData([
            "name": newName
        ]) { error in
            if let error = error {
                self.errorMessage = "Error updating name: \(error.localizedDescription)"
            } else {
                self.userName = newName
            }
        }
    }
}

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

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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
