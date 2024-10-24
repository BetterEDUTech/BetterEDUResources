import SwiftUI

struct HomePageView: View {
    @State private var selectedTab = 0
    
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
            
            Text("BetterEDU Resources")
                .font(.custom("Impact", size: 30))
                .foregroundColor(Color(hex: "5a0ef6")) // Custom color from palette
                .padding(.top)
            
            Text("Student Mental Health Resources")
                .font(.headline)
                .foregroundColor(.white)
            
            // Search Bar
            TextField("Search Resources", text: .constant(""))
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
                .padding(.horizontal)

            // Home & Saved Tabs
            HStack {
                Button(action: {
                    selectedTab = 0 // Home tab
                }) {
                    Text("Home")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTab == 0 ? Color.blue.opacity(0.5) : Color.white.opacity(0.2))
                        .cornerRadius(10)
                }

                Button(action: {
                    selectedTab = 1 // Saved tab
                }) {
                    Text("Saved")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTab == 1 ? Color.blue.opacity(0.5) : Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            // Scrollable Resource List
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Button(action: {
                        // Navigate to Financial Services
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Financial Services")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
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
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Navigation Bar at the Bottom
            HStack {
                Spacer()
                
                Button(action: {
                    // Navigate to Search Page
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
                    // Navigate to Saved Page
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
                    // Navigate to Feedback Page
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
        .background(Color(hex: "251db4").ignoresSafeArea()) // Background color from the mockup
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
