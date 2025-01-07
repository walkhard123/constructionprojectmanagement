import SwiftUI

struct TaskSummarySection: View {
    let projects: [Project]
    
    private var allTasks: [Task] {
        projects.flatMap { $0.tasks }
    }
    
    private var urgentTasks: [Task] {
        allTasks.filter { $0.isUrgent && !$0.isCompleted }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Task Summary")
                .font(.headline)
            
            if !urgentTasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Urgent Tasks")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    
                    ForEach(urgentTasks) { task in
                        UrgentTaskRow(task: task)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
            
            // Other task summaries...
        }
    }
}

struct TaskStatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct UrgentTasksList: View {
    let tasks: [Task]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Urgent Tasks")
                .font(.subheadline)
                .foregroundColor(.red)
            
            ForEach(tasks) { task in
                HStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    Text(task.title)
                        .font(.subheadline)
                    Spacer()
                    Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }
} 