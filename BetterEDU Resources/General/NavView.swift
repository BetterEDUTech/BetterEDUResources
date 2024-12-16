import SwiftUI

struct NavView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    init() {
        // Configure navigation bar appearance for all views
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }

    var body: some View {
        ZStack {
            // Background for the app content
            Color("251db4").ignoresSafeArea()

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
                .background(
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(Color.black)
                                .frame(height: geometry.safeAreaInsets.bottom + 70)
                                .ignoresSafeArea(edges: .bottom)
                        }
                    }
                )
                .onAppear {
                    let tabBarAppearance = UITabBar.appearance()
                    tabBarAppearance.backgroundColor = UIColor.black
                    tabBarAppearance.unselectedItemTintColor = UIColor.lightGray
                    tabBarAppearance.tintColor = UIColor.white
                }
            }
        }
    }
}
