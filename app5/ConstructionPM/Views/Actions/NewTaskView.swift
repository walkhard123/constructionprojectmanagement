import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var taskTitle = ""
    @State private var dueDate = Date()
    @State private var isUrgent = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Task Title", text: $taskTitle)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                Toggle("Mark as Urgent", isOn: $isUrgent)
            }
            .navigationTitle("New Task")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    // TODO: Add task creation logic
                    dismiss()
                }
                .disabled(taskTitle.isEmpty)
            )
        }
    }
} 