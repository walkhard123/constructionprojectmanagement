import SwiftUI

struct TaskListView: View {
    let tasks: [Task]
    let onTaskToggle: (Task) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(tasks) { task in
                TaskRow(task: task, onToggle: onTaskToggle)
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    let onToggle: (Task) -> Void
    
    var body: some View {
        HStack {
            // Completion Toggle
            Button(action: { onToggle(task) }) {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.status == .completed ? .green : .gray)
                    .font(.title3)
            }
            
            // Task Details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.status == .completed)
                    .foregroundColor(task.status == .completed ? .secondary : .primary)
                
                HStack {
                    Label(task.dueDate.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "calendar")
                    
                    if task.isUrgent {
                        Label("Urgent", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status Indicator
            if task.status == .overdue {
                Text("Overdue")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
} 