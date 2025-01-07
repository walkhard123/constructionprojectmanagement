import SwiftUI

struct LogActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProject: Project?
    @State private var activityDescription = ""
    @State private var hoursSpent: Double = 1.0
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    // Project Picker would be implemented here
                    TextEditor(text: $activityDescription)
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
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
            }
            .navigationTitle("Log Activity")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    // TODO: Save activity log
                    dismiss()
                }
                .disabled(activityDescription.isEmpty)
            )
        }
    }
} 