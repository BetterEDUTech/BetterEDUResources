import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct FeedbackView: View {
    @State private var feedbackText: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var userName: String = "[Name]"
    @State private var showSubmissionAlert = false

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 20) {
                            // Add safe area padding at the top
                            Color.clear.frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 95 : 40)
                            
                            // Header Section with Profile Icon
                            HStack {
                                NavigationLink(destination: ProfileView()) {
                                    if let image = profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 35,
                                                   height: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 35)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 4)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 35,
                                                   height: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 35)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 30)
                                Spacer()
                            }
                            .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 10)

                            // Welcome Text
                            Text("Your thoughts matter to us, \(userName). Let us know how we can improve.")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 42 : 35, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40)
                                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 10)

                            // Text Editor for Feedback
                            VStack {
                                TextEditor(text: $feedbackText)
                                    .padding()
                                    .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 400 : 350)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? min(geometry.size.width * 0.7, 800) : .infinity)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 0 : 20)
                            .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 32 : 20)

                            // Submit Button
                            Button(action: {
                                submitFeedback()
                            }) {
                                Text("Submit Feedback")
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16)
                                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? min(geometry.size.width * 0.7, 800) : .infinity)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color(hex: "#5a0ef6"), Color(hex: "#7849fd")]), 
                                                     startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                            }
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 0 : 20)
                            .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 32 : 20)
                            .alert(isPresented: $showSubmissionAlert) {
                                Alert(title: Text("Thank you!"), 
                                     message: Text("Your feedback has been submitted."), 
                                     dismissButton: .default(Text("OK")))
                            }

                            Spacer(minLength: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
                        }
                        .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 130 : -90)
                    }
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 0)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadProfileImage()
            loadUserName()
        }
    }
    
    // Function to load the user's profile image from Firestore
    private func loadProfileImage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error loading profile image URL: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists,
               let profileImageURLString = document.data()?["profileImageURL"] as? String,
               let url = URL(string: profileImageURLString) {
                
                fetchImage(from: url)
            }
        }
    }
    
    // Helper function to fetch an image from a URL
    private func fetchImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching profile image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = uiImage
                }
            }
        }.resume()
    }

    // Function to load the user's name from Firestore
    private func loadUserName() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error loading user name: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists,
               let name = document.data()?["name"] as? String {
                DispatchQueue.main.async {
                    self.userName = name
                }
            }
        }
    }

    // Function to submit feedback to Firestore
    private func submitFeedback() {
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else { return }
        
        let feedbackData: [String: Any] = [
            "userId": uid,
            "userEmail": email,
            "feedbackText": feedbackText,
            "timestamp": Timestamp()
        ]
        
        db.collection("feedback").addDocument(data: feedbackData) { error in
            if let error = error {
                print("Error submitting feedback: \(error.localizedDescription)")
            } else {
                self.feedbackText = "" // Clear feedback text after submission
                self.showSubmissionAlert = true // Show submission confirmation alert
            }
        }
    }
}

#Preview {
    FeedbackView()
}
