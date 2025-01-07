import SwiftUI

struct ProjectSelectionButton: View {
    let selectedProject: Project?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "folder")
                    .foregroundColor(.blue)
                
                if let project = selectedProject {
                    Text(project.name)
                        .foregroundColor(.primary)
                } else {
                    Text("Select Project")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
} 