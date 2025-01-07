import SwiftUI

struct LeaveRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var leaveType = LeaveType.vacation
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var reason = ""
    
    enum LeaveType: String, CaseIterable {
        case vacation = "Vacation"
        case sick = "Sick Leave"
        case personal = "Personal"
        case other = "Other"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Leave Details")) {
                    Picker("Leave Type", selection: $leaveType) {
                        ForEach(LeaveType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                }
                
                Section(header: Text("Reason")) {
                    TextEditor(text: $reason)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Leave Request")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Submit") {
                    // TODO: Submit leave request
                    dismiss()
                }
                .disabled(reason.isEmpty || endDate < startDate)
            )
        }
    }
} 