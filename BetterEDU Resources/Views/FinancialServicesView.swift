import SwiftUI
import Firebase
import FirebaseFirestore

struct FinancialServicesView: View {
    @State private var searchText = ""
    @State private var financialResources: [ResourceItem] = [] // Dynamic resources fetched from Firestore
    private let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text("Financial Services")
                .font(.custom("Impact", size: 35))
                .foregroundColor(Color(hex: "#FFFFFF"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)

            // Search Bar
            Spacer(minLength: 30)
            TextField("Search Resources", text: $searchText)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)

            // Resource List
            ScrollView {
                LazyVStack(spacing: 16) {
                    if filteredResources.isEmpty {
                        Text("No resources found.")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(filteredResources) { resource in
                            ResourceCard(resource: resource)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
        .padding()
        .background(
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationTitle("Financial Services")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: fetchFinancialResources)
    }

    // Fetch financial resources from Firestore
    private func fetchFinancialResources() {
        db.collection("resourcesApp")
            .whereField("Resource Type", isEqualTo: "financial")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching financial resources: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    self.financialResources = documents.compactMap { document in
                        try? document.data(as: ResourceItem.self)
                    }
                }
            }
    }

    // Filter resources based on search text
    private var filteredResources: [ResourceItem] {
        financialResources.filter { resource in
            searchText.isEmpty || resource.title.lowercased().contains(searchText.lowercased())
        }
    }
}

struct FinancialServicesView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialServicesView()
    }
}
