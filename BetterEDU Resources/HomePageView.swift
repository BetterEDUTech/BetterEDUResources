import SwiftUI

struct HomePageView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Section
                HStack {
                    // Navigation link for the profile icon
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.leading)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                
                Text("BetterEDU Resources")
                    .font(.custom("Impact", size: 40))
                    .foregroundColor(Color(hex: "98b6f8")) // Custom color from palette
                    .aspectRatio(contentMode: .fit)
                    .padding(.top)
                
                Text("Mental Health Resources for Students")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Search Bar
                Spacer(minLength: 1)
                TextField("Search Resources", text: .constant(""))
                    .padding()
                    .background(Color(hex: "98b6f8"))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                // HStack for FAQ and Saved tabs
                HStack {
                    // FAQ Tab
                    Button(action: {
                        selectedTab = 0 // Home tab
                    }) {
                        Text("FAQ")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "98b6f8"))
                            .foregroundColor(Color(hex: "251db4"))
                            .cornerRadius(10)
                    }
                    
                    // Saved Tab
                    Button(action: {
                        selectedTab = 1 // Saved tab
                    }) {
                        Text("Saved")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "98b6f8"))
                            .foregroundColor(Color(hex: "251db4"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 1)
                
                // Scrollable Resource List
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Button(action: {
                            // Navigate to Financial Services
                        }) {
                            HStack {
                                Image(systemName: "building.columns.fill")
                                Text("Financial Services")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color(hex: "251db4"))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Navigate to Emergency Hotlines
                        }) {
                            HStack {
                                Image(systemName: "phone.arrow.up.right.fill")
                                Text("Emergency Hotlines")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color(hex: "251db4"))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Navigate to Self-Care Resources
                        }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                Text("Self-Care Resources")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color(hex: "251db4"))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Navigate to Academic Stress Support
                        }) {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("Academic Stress Support")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color(hex: "251db4"))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
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
            .background(Color(hex: "251db4").ignoresSafeArea()) // Background color from the mockup
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

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

// Custom extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
