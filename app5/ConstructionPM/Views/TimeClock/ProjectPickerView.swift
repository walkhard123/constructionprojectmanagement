import SwiftUI

struct ProjectPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let projects: [Project]
    @Binding var selectedProjectId: UUID?
    
    var body: some View {
        NavigationView {
            List {
                Button {
                    selectedProjectId = nil
                    dismiss()
                } label: {
                    HStack {
                        Text("No Project")
                        Spacer()
                        if selectedProjectId == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ForEach(projects) { project in
                    Button {
                        selectedProjectId = project.id
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(project.name)
                                Text(project.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedProjectId == project.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
} 