import SwiftUI

struct ContentView: View {
    @StateObject private var userViewModel = UserViewModel()
    @State private var showLogin = false
    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                if let user = userViewModel.user {
                    Text("Hello, \(user.name)")
                    
                } else {
                    Text("Welcome! Please login to the app to use it.")
                }
                Button("Login") {
                    showLogin = true
                }
            }
            .navigationDestination(isPresented: $showLogin){LoginView()}
            .task{
                await userViewModel.fetchUser()
            }
            .padding(10)
        }
    }
}


#Preview {
    ContentView()
}
