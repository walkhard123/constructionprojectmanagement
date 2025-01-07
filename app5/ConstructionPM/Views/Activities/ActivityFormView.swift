import SwiftUI

struct ActivityFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var activityViewModel: ActivityViewModel
    let project: Project?
    
    @State private var description = ""
    @State private var hoursSpent: Double = 1.0
    @State private var date = Date()
    @State private var activityType = Activity.ActivityType.development
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    if project == nil {
                        Text("No Project Selected")
                            .foregroundColor(.secondary)
                    } else {
                        Text(project?.name ?? "")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Type", selection: $activityType) {
                        ForEach(Activity.ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2))
                        )
                    
                    Stepper(value: $hoursSpent, in: 0.5...12, step: 0.5) {
                        HStack {
                            Text("Hours Spent:")
                            Text("\(hoursSpent, specifier: "%.1f")")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Log Activity")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveActivity()
                    dismiss()
                }
                .disabled(description.isEmpty || project == nil)
            )
        }
    }
    
    private func saveActivity() {
        guard let project = project else { return }
        
        let activity = Activity(
            id: UUID(),
            projectId: project.id,
            description: description,
            hoursSpent: hoursSpent,
            date: date,
            type: activityType
        )
        
        activityViewModel.addActivity(activity)
    }
} 