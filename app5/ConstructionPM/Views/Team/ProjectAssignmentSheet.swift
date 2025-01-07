import SwiftUI

struct ProjectAssignmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let member: TeamMember
    @ObservedObject var viewModel: TeamViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(projectViewModel.projects) { project in
                    ProjectAssignmentRow(
                        project: project,
                        isAssigned: member.assignedProjects.contains(project.id),
                        onToggle: {
                            if member.assignedProjects.contains(project.id) {
                                viewModel.removeFromProject(memberId: member.id, projectId: project.id)
                            } else {
                                viewModel.assignToProject(memberId: member.id, projectId: project.id)
                            }
                        }
                    )
                }
            }
            .navigationTitle("Assign Projects")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct ProjectAssignmentRow: View {
    let project: Project
    let isAssigned: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                VStack(alignment: .leading) {
                    Text(project.name)
                        .font(.headline)
                    Text("\(Int(project.progressPercentage))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isAssigned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .buttonStyle(.plain)
    }
} 