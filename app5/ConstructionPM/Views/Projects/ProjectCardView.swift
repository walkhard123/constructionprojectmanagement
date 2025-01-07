import SwiftUI

struct ProjectCardView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(project.name)
                    .font(.headline)
                Spacer()
                StatusBadge(status: project.status)
            }
            
            // Description
            if !project.description.isEmpty {
                Text(project.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: project.progressPercentage, total: 100)
                    .tint(project.isUrgent ? .red : .blue)
                
                HStack {
                    Text("\(Int(project.progressPercentage))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if project.isUrgent {
                        Label("Urgent", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Stats
            HStack(spacing: 16) {
                Label("\(project.daysRemaining) days left", systemImage: "clock")
                Spacer()
                Label("\(project.tasks.count) tasks", systemImage: "checklist")
                if project.overdueTasksCount > 0 {
                    Label("\(project.overdueTasksCount) overdue", systemImage: "exclamationmark.circle")
                        .foregroundColor(.red)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 