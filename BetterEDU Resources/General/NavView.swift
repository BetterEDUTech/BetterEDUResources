import SwiftUI

class TabViewModel: ObservableObject {
    @Published var selectedTab = 0
}

struct NavView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var tabViewModel = TabViewModel()

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
                TabView(selection: $tabViewModel.selectedTab) {
                    HomePageView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)

                    ResourcesAppView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(1)

                    SavedView()
                        .tabItem {
                            Label("Saved", systemImage: "heart.fill")
                        }
                        .tag(2)

                    FeedbackView()
                        .tabItem {
                            Label("Feedback", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .tag(3)
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
        .environmentObject(tabViewModel)
    }
}
