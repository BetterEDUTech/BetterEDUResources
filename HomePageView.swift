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
                    .foregroundColor(.white)
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
               // Spacer(minLength: 1)
            //HStack for faq and saved tabs
            HStack {
                // FAQ Tab
                Button(action: {
                    selectedTab = 0 // Home tab
                }) {    // creating the text for the FAQ button w/ proper color and padding
                        Text("FAQ")
                            //.font(.custom("Tan Tangkiwood-Regular", size: 16))
                                // wasn't able to find a fre tangikwood font file
                            .frame(maxWidth: .infinity)
                            .padding()
                            // setting the foreground and background color
                            .background(selectedTab == 0 ?
                                        Color(hex:"98b6f8"):
                                        Color(hex: "98b6f8"))
                            .foregroundColor(Color(hex: "251db4"))
                            .cornerRadius(10)
                    }
                // saved tab
                Button(action: {
                    selectedTab = 1 // Saved tab
                }) {
                    // creating the text for the saved button w/ proper color and padding
                    Text("Saved")
                        .frame(maxWidth: .infinity)
                        .padding()
                        // setting the foreground and background color
                        .background(selectedTab == 1 ?
                                    Color(hex: "98b6f8"):
                                    Color(hex: "98b6f8"))
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

            // Navigation Bar at the Bottom
            HStack {
                Spacer()
                Button(action: {
                        // Navigate to Home Page
                        selectedTab = 0 // Example action for Home
                    }) {
                        VStack {
                            Image(systemName: "house.fill") // House icon
                                .foregroundColor(Color.white) // Icon color
                            Text("Home") // Label for the button
                                .font(.footnote)
                                .foregroundColor(Color.white) // Text color
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == 0 ? .blue : .white)
                
                Button(action: {
                    // Navigate to Search Page
                }) {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.white)
                        Text("Search")
                            .font(.footnote)
                            .foregroundColor(Color.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == 1 ? .blue : .white)

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
                .foregroundColor(selectedTab == 2 ? .blue : .white)

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
                .foregroundColor(selectedTab == 3 ? .blue : .white)

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
