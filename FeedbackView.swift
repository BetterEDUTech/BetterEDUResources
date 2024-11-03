
import SwiftUI

struct FeedbackView: View {
    @State private var feedbackText: String = "" // State variable to bind text input
    @State private var selectedTab = 2 // Set the default tab to Feedback

    var body: some View {
        VStack(spacing: 20) {
            // Header Section
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading)

                Spacer()
            }

            // Welcome Text
            // TODO: Replace [Name] with actuall user name
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

            // Navigation Bar at the Bottom
            HStack {
                Spacer()

                Button(action: {
                    selectedTab = 0 // Navigate to Search
                }) {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                            .font(.footnote)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == 0 ? .blue : .white)

                Spacer()

                Button(action: {
                    selectedTab = 1 // Navigate to Saved
                }) {
                    VStack {
                        Image(systemName: "heart.fill")
                        Text("Saved")
                            .font(.footnote)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == 1 ? .blue : .white)

                Spacer()

                Button(action: {
                    selectedTab = 2 // Stay on Feedback
                }) {
                    VStack {
                        Image(systemName: "message.fill")
                        Text("Feedback")
                            .font(.footnote)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == 2 ? .blue : .white)

                Spacer()
            }
            .padding()
            .background(Color.black)
        }
        .background(Color(hex: "251db4").ignoresSafeArea()) // Background color from HomePageView
    }
}

#Preview {
    FeedbackView()
}



