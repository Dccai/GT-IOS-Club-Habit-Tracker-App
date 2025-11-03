import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    private let db = Firestore.firestore()
    
    func addUser(user: User) async throws{
        do {
            let userStr: String = user.id ?? ""
            try await db.collection("users").document(userStr).setData(
                [
                    "id": userStr,
                    "name": user.name,
                    "email": user.email,
                    "habits": user.habits
                ]
            )
        } catch {
            print("Error adding user")
            throw error
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            isAuthenticated = false
            return
        }
        
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            guard let data = doc.data() else {return}
            
            self.user = User(
                id:uid,
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                habits: data["habits"] as? [Habit] ?? []
                
            )
            self.isAuthenticated = true
        } catch {
            print("Need to log in")
            
        }
    }
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            self.user = nil
            self.isAuthenticated = false
            
        } catch {
            print("Error signing out")
        }
    }
}
