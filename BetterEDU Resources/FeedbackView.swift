import SwiftUI

struct FeedbackView: View {
    @State private var feedbackText: String = "" // State variable to bind text input
    @State private var selectedTab = 2 // Set the default tab to Feedback

    var body: some View {
        NavigationView {
            VStack {
                // Header Section with Profile Icon
                HStack {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    Spacer()
                }
                .padding(.top)

                // Welcome Text with Updated Font and Message
                Text("Your thoughts matter to us, [Name]. Let us know how we can improve.")
                    .font(.custom("Impact", size: 24)) // Using Impact font for bold appearance
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)

                // Text Editor with Professional Styling
                TextEditor(text: $feedbackText)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                // Submit Button with Enhanced Styling
                Button(action: {
                    print("Feedback Submitted: \(feedbackText)")
                }) {
                    Text("Submit Feedback")
                        .font(.custom("Impact", size: 18)) // Using Impact for bold button text
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(hex: "#5a0ef6"), Color(hex: "#7849fd")]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

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
            .background(Color(hex: "251db4").ignoresSafeArea()) // Background color from palette
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

