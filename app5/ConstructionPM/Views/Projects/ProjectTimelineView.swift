import SwiftUI

struct ProjectTimelineView: View {
    let project: Project
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Project Progress Overview
                ProgressOverview(project: project)
                
                // Timeline
                VStack(alignment: .leading, spacing: 16) {
                    Text("Timeline")
                        .font(.headline)
                    
                    TimelineContent(project: project)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgressOverview: View {
    let project: Project
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress Bar
            ProgressView(value: project.progressPercentage, total: 100)
                .tint(project.isUrgent ? .red : .blue)
            
            // Key Dates
            HStack {
                DateLabel(title: "Start", date: project.startDate)
                Spacer()
                DateLabel(title: "Due", date: project.dueDate)
            }
            .font(.caption)
            
            // Status
            if project.isOverdue {
                Label("Project is overdue", systemImage: "exclamationmark.circle")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else if project.daysRemaining > 0 {
                Label("\(project.daysRemaining) days remaining", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct TimelineContent: View {
    let project: Project
    
    private var sortedTasks: [Task] {
        project.tasks.sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if project.tasks.isEmpty {
                EmptyTimelineView()
            } else {
                ForEach(sortedTasks) { task in
                    TimelineTaskItem(task: task)
                }
            }
        }
    }
}

struct TimelineTaskItem: View {
    let task: Task
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Circle
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .strikethrough(task.status == .completed)
                
                Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Task Status
            statusLabel
        }
    }
    
    private var statusColor: Color {
        switch task.status {
        case .completed: return .green
        case .overdue: return .red
        case .inProgress: return task.isUrgent ? .orange : .blue
        }
    }
    
    @ViewBuilder
    private var statusLabel: some View {
        switch task.status {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .overdue:
            Text("Overdue")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red)
                .cornerRadius(4)
        case .inProgress:
            if task.isUrgent {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
            }
        }
    }
}

struct DateLabel: View {
    let title: String
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .foregroundColor(.secondary)
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .fontWeight(.medium)
        }
    }
}

struct EmptyTimelineView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No tasks yet")
                .font(.headline)
            Text("Add tasks to see them on the timeline")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
} 