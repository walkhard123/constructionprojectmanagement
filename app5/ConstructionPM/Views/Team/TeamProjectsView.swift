import SwiftUI

struct TeamProjectsView: View {
    @ObservedObject var viewModel: TeamViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    @State private var showingAssignmentSheet = false
    @State private var selectedMember: TeamMember?
    
    var body: some View {
        List {
            ForEach(viewModel.members.filter { $0.isActive }) { member in
                TeamProjectAssignmentRow(
                    member: member,
                    projects: assignedProjects(for: member),
                    onTap: {
                        selectedMember = member
                        showingAssignmentSheet = true
                    }
                )
            }
        }
        .sheet(isPresented: $showingAssignmentSheet) {
            if let member = selectedMember {
                ProjectAssignmentSheet(
                    member: member,
                    viewModel: viewModel,
                    projectViewModel: projectViewModel
                )
            }
        }
    }
    
    private func assignedProjects(for member: TeamMember) -> [Project] {
        projectViewModel.projects.filter { project in
            member.assignedProjects.contains(project.id)
        }
    }
}

struct TeamProjectAssignmentRow: View {
    let member: TeamMember
    let projects: [Project]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(member.name)
                        .font(.headline)
                    Spacer()
                    Text("\(projects.count) projects")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !projects.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(projects) { project in
                                ProjectBadge(project: project)
                            }
                        }
                    }
                } else {
                    Text("No assigned projects")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct ProjectBadge: View {
    let project: Project
    
    var body: some View {
        Text(project.name)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(project.isUrgent ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
            .foregroundColor(project.isUrgent ? .red : .blue)
            .cornerRadius(4)
    }
} 