import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.status == .completed ? .green : .gray)
            }
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.status == .completed)
                
                Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if task.isUrgent {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
            }
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
} 