import SwiftUI

enum TabSelection {
    case habits
    case stats
    case profile
}

struct ContentView: View {
    @State private var selectedTab: TabSelection = .habits
    
    var body: some View {
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
    var body: some View {
        VStack {
            Text("Profile")
                .font(.system(size: 34, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
