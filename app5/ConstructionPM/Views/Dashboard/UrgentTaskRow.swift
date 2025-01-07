import SwiftUI

struct UrgentTaskRow: View {
    let task: Task

    var body: some View {
        HStack {
            Text(task.title)
            Spacer()
            Text(task.dueDate, style: .date)
        }
    }
} 