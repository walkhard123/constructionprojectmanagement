import SwiftUI

struct ProjectTasksSection: View {
    let tasks: [Task]
    let onTaskToggle: (Task) -> Void
    let onTaskEdit: (Task) -> Void
    let onTaskMove: ((IndexSet, Int) -> Void)?
    @Binding var selectedFilter: TaskFilter
    
    var filteredTasks: [Task] {
        switch selectedFilter {
        case .all:
            return tasks
        case .active:
            return tasks.filter { !$0.isCompleted }
        case .completed:
            return tasks.filter { $0.isCompleted }
        case .overdue:
            return tasks.filter { !$0.isCompleted && $0.dueDate < Date() }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if filteredTasks.isEmpty {
                Text("No tasks found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(filteredTasks) { task in
                    TaskRowView(
                        task: task,
                        onToggle: { onTaskToggle(task) },
                        onEdit: { onTaskEdit(task) }
                    )
                    if task.id != filteredTasks.last?.id {
                        Divider()
                    }
                }
                .onMove(perform: onTaskMove)
            }
        }
    }
}

#Preview {
    ProjectTasksSection(
        tasks: [],
        onTaskToggle: { _ in },
        onTaskEdit: { _ in },
        onTaskMove: nil,
        selectedFilter: .constant(.all)
    )
} 