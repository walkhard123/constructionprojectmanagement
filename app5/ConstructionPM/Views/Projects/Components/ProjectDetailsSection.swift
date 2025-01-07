import SwiftUI

struct ProjectDetailsSection: View {
    let project: Project
    
    var body: some View {
        Group {
            ProjectInfoRow(label: "Status", value: project.status.rawValue)
            ProjectInfoRow(label: "Progress", value: "\(Int(project.progressPercentage))%")
            ProjectInfoRow(label: "Due Date", value: project.dueDate.formatted(date: .abbreviated, time: .omitted))
            if project.isUrgent {
                Label("Urgent Project", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    List {
        Section(header: Text("Project Details")) {
            ProjectDetailsSection(
                project: try! Project(
                    id: UUID(),
                    name: "Sample Project",
                    description: "A sample project",
                    address: "123 Main St",
                    projectType: .house,
                    startDate: Date(),
                    dueDate: Date().addingTimeInterval(30*24*60*60),
                    progressPercentage: 50,
                    tasks: [],
                    isUrgent: true,
                    status: .inProgress,
                    assignedTeamMembers: []
                )
            )
        }
    }
} 