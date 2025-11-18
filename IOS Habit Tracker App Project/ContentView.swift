import SwiftUI

enum TabSelection {
    case habits
    case stats
    case profile
}

struct ContentView: View {
    @StateObject private var userViewModel = UserViewModel()
    @State private var selectedTab: TabSelection = .habits
    @State private var showLogin = false
    
    var body: some View {
        Group {
            if userViewModel.isAuthenticated {
                VStack(spacing: 0) {
                    // Content area
                    Group {
                        switch selectedTab {
                        case .habits:
                            HabitLogView()
                        case .stats:
                            StatLogView()
                        case .profile:
                            ProfileView()
                        }
                    }
                    
                    // Custom Tab Bar
                    HStack(spacing: 0) {
                        TabBarButton(
                            icon: "checkmark.square.fill",
                            title: "Habits",
                            isSelected: selectedTab == .habits
                        ) {
                            selectedTab = .habits
                        }
                        
                        TabBarButton(
                            icon: "chart.line.uptrend.xyaxis.circle",
                            title: "Stats",
                            isSelected: selectedTab == .stats
                        ) {
                            selectedTab = .stats
                        }
                        
                        TabBarButton(
                            icon: "person.fill",
                            title: "Profile",
                            isSelected: selectedTab == .profile
                        ) {
                            selectedTab = .profile
                        }
                    }
                    .frame(height: 80)
                    .background(Color(UIColor.systemBackground))
                    .overlay(
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 0.5),
                        alignment: .top
                    )
                }
                .edgesIgnoringSafeArea(.bottom)
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    Text("Habit Tracker")
                        .font(.system(size:40,weight:.bold))
                    Text("Track your daily habits and reach your goals")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    Spacer()
                    Button("Get Started") {
                        showLogin = true
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom,50)
                
                }
                .sheet(isPresented: $showLogin) {
                    LoginView()
                        .environmentObject(userViewModel)
                }
            }
        }
        .task {
            await userViewModel.fetchUser()
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? .blue : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// Placeholder Profile View
struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        VStack (spacing:20) {
            Text("Profile")
                .font(.system(size: 34, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            if let user = userViewModel.user {
                VStack (alignment: .leading, spacing: 15){
                    HStack {
                        Text("Name:")
                            .fontWeight(.semibold)
                        Text(user.name)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Email:")
                            .fontWeight(.semibold)
                        Text(user.email)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    
                    HStack {
                        Text("Total Habits:")
                            .fontWeight(.semibold)
                        Text("\(userViewModel.habits.count)")
                            .foregroundStyle(.secondary)
                        
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            Spacer()
            
            Button("Sign Out") {
                userViewModel.signOut()
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(10)
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
