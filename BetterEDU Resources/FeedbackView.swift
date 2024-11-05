import SwiftUI

struct FeedbackView: View {
    @State private var feedbackText: String = "" // State variable to bind text input
    @State private var selectedTab = 2 // Set the default tab to Feedback

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Section with Profile Icon
                HStack {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    Spacer()
                }

                // Welcome Text
                // TODO: Replace [Name] with actual user name
                Text("Hi [Name],\nplease enter your feedback here!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()

                // Text Field for Feedback Input
                TextField("Type here..", text: $feedbackText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)

                // Submit Button
                Button(action: {
                    print("Feedback Submitted: \(feedbackText)")
                }) {
                    Text("Submit")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }

                Spacer()
                
                // Bottom Navigation Bar
                HStack {
                    Spacer()
                    navBarButton(icon: "house", label: "Home", action: {})
                    Spacer()
                    navBarButton(icon: "magnifyingglass", label: "Search", action: {})
                    Spacer()
                    navBarButton(icon: "heart.fill", label: "Saved", action: {})
                    Spacer()
                    navBarButton(icon: "line.3.horizontal.decrease.circle", label: "Filter", action: {})
                    Spacer()
                }
                .padding()
                .background(Color.black)
            }
            .background(Color(hex: "251db4").ignoresSafeArea()) // Background color from HomePageView
        }
    }
}

// Helper function for the bottom navigation buttons
private func navBarButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        VStack {
            Image(systemName: icon)
            Text(label).font(.footnote)
        }
        .foregroundColor(.white)
    }
}

#Preview {
    FeedbackView()
}
