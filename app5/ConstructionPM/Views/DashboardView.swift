import SwiftUI

struct DashboardView: View {
    @State private var projects: [Project] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Project Progress Section
                    ProjectProgressSection(projects: projects)
                    
                    // Task Summary Section
                    TaskSummarySection(projects: projects)
                    
                    // Quick Actions Section
                    QuickActionsSection()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { /* Add new project action */ }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct ProjectProgressSection: View {
    let projects: [Project]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Project Progress")
                .font(.headline)
            
            ForEach(projects) { project in
                ProjectProgressRow(project: project)
            }
        }
    }
}

struct ProjectProgressRow: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(project.name)
                .foregroundColor(project.isUrgent ? .red : .primary)
            
            ProgressView(value: project.progressPercentage, total: 100)
                .tint(project.isUrgent ? .red : .blue)
            
            Text("\(Int(project.progressPercentage))%")
                .font(.caption)
        }
    }
} 