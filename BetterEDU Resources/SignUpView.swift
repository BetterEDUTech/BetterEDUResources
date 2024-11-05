import SwiftUI
import PhotosUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var profileImage: UIImage? = nil
    @State private var showingImagePicker = false

    var body: some View {
        ZStack {
            // Background color
            Color(hex: "251db4").ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Profile Image Selector
                VStack {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            VStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                                Text("Upload Profile Picture")
                                    .foregroundColor(.white)
                                    .font(.footnote)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)

                // Title
                Text("Create an Account")
                    .font(.custom("Impact", size: 28))
                    .foregroundColor(.white)
                    .padding()

                // Name TextField
                VStack(alignment: .leading, spacing: 10) {
                    Text("Name")
                        .font(.custom("Impact", size: 18))
                        .foregroundColor(.white)
                    
                    TextField("Enter your name", text: $name)
                        .padding()
                        .background(Color(hex: "98b6f8"))
                        .cornerRadius(10)
                        .foregroundColor(Color(hex: "251db4"))
                }

                // Email TextField
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email")
                        .font(.custom("Impact", size: 18))
                        .foregroundColor(.white)
                    
                    TextField("name@example.com", text: $email)
                        .padding()
                        .background(Color(hex: "98b6f8"))
                        .cornerRadius(10)
                        .foregroundColor(Color(hex: "251db4"))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                // Password SecureField with toggle
                VStack(alignment: .leading, spacing: 10) {
                    Text("Password")
                        .font(.custom("Impact", size: 18))
                        .foregroundColor(.white)

                    ZStack(alignment: .trailing) {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .padding()
                                .background(Color(hex: "98b6f8"))
                                .cornerRadius(10)
                                .foregroundColor(Color(hex: "251db4"))
                        } else {
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color(hex: "98b6f8"))
                                .cornerRadius(10)
                                .foregroundColor(Color(hex: "251db4"))
                        }

                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 10)
                    }
                }

                // Sign Up Button
                Button(action: {
                    // Sign Up Action
                }) {
                    Text("Sign Up")
                        .font(.custom("Impact", size: 30))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $profileImage)
            }
        }
    }
}


// ImagePicker struct to handle image selection
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { (image, _) in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
