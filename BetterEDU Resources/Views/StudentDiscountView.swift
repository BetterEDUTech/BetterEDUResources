import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct StudentDiscountView: View {
    @State private var resources: [ResourceItem] = []
    @State private var searchText: String = ""
    @State private var selectedFilter: String = "All"
    @State private var availableFilters: [String] = ["All"]
    private var db = Firestore.firestore()
    
    @State private var profileImage: UIImage? = nil

    private var gridColumns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ]
        } else {
            return [GridItem(.flexible())]
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header with profile icon
                HStack {
                    NavigationLink(destination: ProfileView().navigationBarHidden(true)) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 35, 
                                       height: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 35)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 4)
                                .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 35, 
                                       height: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 35)
                                .foregroundColor(.white)
                                .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                        }
                    }
                    Spacer()
                }
                .padding(.top)
                .onAppear(perform: {
                    loadProfileImage()
                    fetchResources()
                })
                
                // Title
                Text("Student Discounts")
                    .font(.custom("Lobster1.4", size: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 60))
                    .foregroundColor(.white)
                    .padding(.top, -1)
                    .padding(.bottom, -10)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Search and Filter Section
                HStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search discounts...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    // Filter Menu
                    Menu {
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(availableFilters, id: \.self) { filter in
                                Text(filter).tag(filter)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedFilter)
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14))
                                .foregroundColor(.white)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 12 : 10))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                .padding(.top, 10)

                // Display filtered resources
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16) {
                        if filteredResources.isEmpty {
                            Text("No discounts found.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .gridCellColumns(gridColumns.count)
                        } else {
                            ForEach(filteredResources) { resource in
                                ResourceCard(resource: resource)
                            }
                        }
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
                    .padding(.top, 12)
                    .padding(.bottom, 90)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func fetchResources() {
        db.collection("studentDisc")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("No documents found in studentDisc.")
                        return
                    }
                    
                    let fetchedResources = documents.compactMap { document in
                        do {
                            return try document.data(as: ResourceItem.self)
                        } catch {
                            print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                            return nil
                        }
                    }
                    DispatchQueue.main.async {
                        self.resources = fetchedResources
                        updateAvailableFilters()
                    }
                }
            }
    }

    private func updateAvailableFilters() {
        let types = Set(resources.compactMap { $0.resourceType })
        availableFilters = ["All"] + Array(types).sorted()
    }

    private var filteredResources: [ResourceItem] {
        resources.filter { resource in
            let matchesFilter = (selectedFilter == "All" || resource.resourceType == selectedFilter)
            let matchesSearch = searchText.isEmpty || resource.title.lowercased().contains(searchText.lowercased())
            return matchesFilter && matchesSearch
        }
    }

    private func loadProfileImage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists,
               let profileImageURLString = document.data()?["profileImageURL"] as? String,
               let url = URL(string: profileImageURLString) {
                fetchImage(from: url)
            }
        }
    }

    private func fetchImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching profile image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = uiImage
                }
            }
        }.resume()
    }
}

struct StudentDiscountView_Previews: PreviewProvider {
    static var previews: some View {
        StudentDiscountView()
    }
} 