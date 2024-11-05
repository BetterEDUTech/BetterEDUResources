import SwiftUI

struct SavedView: View {
    // State to manage the list of saved resources (could be populated dynamically)
    @State private var savedResources: [Resource] = [
        Resource(imageName: "financial_resources", title: "Financial Resources", subtitle: "Saved"),
        Resource(imageName: "educational_resources", title: "Educational Resources", subtitle: "Saved"),
        Resource(imageName: "mental_health_resources", title: "Mental Health Resources", subtitle: "Saved")
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(hex: "251db4").ignoresSafeArea()

                VStack(spacing: 20) {
                    // Header with profile icon
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

                    // Title
                    Text("My saved resources")
                        .font(.custom("Impact", size: 28))
                        .foregroundColor(.white)
                        .padding()

                    // Scrollable grid of saved resources
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(savedResources) { resource in
                                ResourceView(resource: resource)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()

                    // Navigation Bar
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
}

// Resource model conforming to Identifiable for dynamic lists
struct Resource: Identifiable {
    let id = UUID() // Unique ID for each resource
    let imageName: String
    let title: String
    let subtitle: String
}

// View for individual saved resources
struct ResourceView: View {
    let resource: Resource

    var body: some View {
        VStack {
            Image(resource.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .cornerRadius(10)

            Text(resource.title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 5)

            Text(resource.subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    SavedView()
}
