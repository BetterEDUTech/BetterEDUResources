import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

class FirestoreManager: ObservableObject {
    @Published var resources: String = ""
    init() {
        fetchAllResources()
    }
    
    func fetchAllResources() {
        let db = Firestore.firestore()
        
        db.collection("resourcesApp").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID): \(document.data())")
                }
            }
        }
    }
}
