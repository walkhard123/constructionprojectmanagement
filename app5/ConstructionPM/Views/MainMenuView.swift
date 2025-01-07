import SwiftUI

struct MainMenuView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var taskViewModel: TaskViewModel
    
    let menuItems: [MenuItem] = [
        MenuItem(title: "Dashboard", icon: "chart.pie.fill", color: .blue),
        MenuItem(title: "Projects", icon: "folder.fill", color: .orange),
        MenuItem(title: "Tasks", icon: "checklist", color: .green),
        MenuItem(title: "Time Clock", icon: "clock.fill", color: .purple),
        MenuItem(title: "Daily Logs", icon: "doc.text.fill", color: .cyan),
        MenuItem(title: "Files", icon: "doc.fill", color: .yellow),
        MenuItem(title: "Team", icon: "person.2.fill", color: .pink),
        MenuItem(title: "Settings", icon: "gear", color: .gray)
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(menuItems) { item in
                        NavigationLink(destination: destinationView(for: item)) {
                            MenuCardView(item: item)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Construction PM")
        }
    }
    
    @ViewBuilder
    private func destinationView(for item: MenuItem) -> some View {
        switch item.title {
        case "Dashboard":
            DashboardView(projectViewModel: projectViewModel, taskViewModel: taskViewModel)
        case "Projects":
            ProjectListView(projectViewModel: projectViewModel)
        case "Tasks":
            TasksView(taskViewModel: taskViewModel, projectViewModel: projectViewModel)
        case "Time Clock":
            TimeClockView(projectViewModel: projectViewModel)
        case "Daily Logs":
            DailyLogView(projectViewModel: projectViewModel)
        case "Files":
            FileManagerView()
        case "Team":
            TeamView(projectViewModel: projectViewModel)
        case "Settings":
            SettingsView()
        default:
            Text("Coming Soon")
        }
    }
}

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

struct MenuCardView: View {
    let item: MenuItem
    
    var body: some View {
        VStack {
            Image(systemName: item.icon)
                .font(.system(size: 24))
                .foregroundColor(item.color)
                .frame(width: 50, height: 50)
                .background(item.color.opacity(0.2))
                .clipShape(Circle())
            
            Text(item.title)
                .font(.callout)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text("View Details")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 