import SwiftUI
import PhotosUI

struct PersonalInformationView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    
    // Dismiss action to navigate back
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(hex: "3b3aaf"), Color(hex: "1d1ba9")]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                
                // Custom Back Arrow in the Top-Left Corner
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                    Spacer()
                }
                .padding([.top, .leading])

                Text("Personal Information")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, -10)

                // Profile Picture Upload Section
                VStack {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 4)
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                            )
                            .shadow(radius: 4)
                    }
                    
                    // "Change Profile Picture" Text Button
                    Text("Change Profile Picture")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.top, 8)
                        .onTapGesture {
                            isShowingImagePicker = true
                        }
                }
                .frame(maxWidth: .infinity) // Center the profile picture section
                .padding(.bottom, 20)
                
                // Name Field
                VStack(alignment: .leading, spacing: 10) {
                    Text("Name")
                        .foregroundColor(.white)
                        .font(.headline)
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.8))
                        TextField("Enter your name", text: $name)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                }

                // Email Field
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email")
                        .foregroundColor(.white)
                        .font(.headline)
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white.opacity(0.8))
                        TextField("Enter your email", text: $email)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                }

                Spacer()
                
                // Save Button with a distinct style
                Button(action: {
                    // Save action for name and email
                    savePersonalInformation()
                }) {
                    Text("Save")
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "251db4"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
            }
            .padding()
            .navigationBarHidden(true) // Hide the default navigation bar
            .sheet(isPresented: $isShowingImagePicker) {
                PhotoPicker(selectedImage: $profileImage)
            }
        }
    }
    
    // Placeholder function to handle save action
    private func savePersonalInformation() {
        // Code to save the name and email, e.g., storing in UserDefaults or database
        print("Saved Name: \(name), Email: \(email)")
    }
}

// Renamed to PhotoPicker to avoid conflict
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    PersonalInformationView()
}
