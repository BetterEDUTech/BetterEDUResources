import SwiftUI

struct NavView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Background for the app content
            Color(hex: "251db4").ignoresSafeArea()

            VStack(spacing: 0) {
                // Main content
                TabView {
                    HomePageView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }

                    ResourcesAppView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }

                    SavedView()
                        .tabItem {
                            Label("Saved", systemImage: "heart.fill")
                        }

                    FeedbackView()
                        .tabItem {
                            Label("Feedback", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                }
                .accentColor(.white) // Selected icon and text
                .onAppear {
                    let tabBarAppearance = UITabBar.appearance()
                    tabBarAppearance.backgroundColor = UIColor.black // Black background
                    tabBarAppearance.unselectedItemTintColor = UIColor.lightGray // Inactive tabs
                    tabBarAppearance.tintColor = UIColor.white // Active tab color
                }
            }
        }
    }
}
