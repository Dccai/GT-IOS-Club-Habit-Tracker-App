import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var habits: [Habit] = []
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
                    "email": user.email
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
                habits: []
                
            )
            self.isAuthenticated = true
            await fetchHabits()
        } catch {
            print("Need to log in")
            errorMessage = error.localizedDescription
            
        }
    }
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            self.user = nil
            self.habits = []
            self.isAuthenticated = false
            
        } catch {
            print("Error signing out")
            errorMessage = error.localizedDescription
        }
    }
    func fetchHabits() async {
        guard let uid = user?.id else {
            print("No user ID available")
            return
        }
        do {
            let snapshot = try await db.collection("users")
                .document(uid)
                .collection("habits")
                .getDocuments()
            self.habits = snapshot.documents.compactMap{doc in
                try? doc.data(as: Habit.self)
            }
        } catch {
            print("Error fetching habits")
            errorMessage = error.localizedDescription
        }
    }
    func addHabit(_ habit: Habit) async throws{
        guard let uid = user?.id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        do {
            let habitRef = db.collection("users")
                .document(uid)
                .collection("habits")
                .document()
            var habitToSave = habit
            habitToSave.id = habitRef.documentID
            try habitRef.setData(from: habitToSave)
            await fetchHabits()
        } catch {
            print("Error adding habit")
            throw error
        }
    }
    func updateHabt(_ habit: Habit) async throws {
        guard let uid = user?.id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"No user logged in"])
            
        }
        guard let habitId = habit.id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"Habit has no id"])
        }
        do {
            try db.collection("users")
                .document(uid)
                .collection("habits")
                .document(habitId)
                .setData(from: habit)
            if let index = habits.firstIndex(where: {$0.id == habitId}) {
                habits[index] = habit
            }
        } catch {
            print("Error updating habit")
            throw error
        }
    }
    func deleteHabit (_ habit: Habit) async throws {
        guard let uid = user?.id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"No user logged in"])
            
        }
        guard let habitId = habit.id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"Habit has no id"])
        }
        do {
            try await db.collection("users")
                .document(uid)
                .collection("habits")
                .document(habitId)
                .delete()
            habits.removeAll{$0.id == habitId}
        } catch {
            print("Error deleting habit")
            throw error
        }
    }
    func updateHabitProgress(_ habit:Habit, newProgress: Int) async throws {
        guard let uid = user?.id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"No user logged in"])
            
        }
        guard let habitId = habit.id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"Habit has no id"])
        }
        do {
            try await db.collection("users")
                .document(uid)
                .collection("habits")
                .document(habitId)
                .updateData(["progress": newProgress])
            if let index = habits.firstIndex(where: {$0.id == habitId}) {
                habits[index].progress = newProgress
            }
        } catch {
            print("Error deleting habit")
            throw error
        }    }
}
