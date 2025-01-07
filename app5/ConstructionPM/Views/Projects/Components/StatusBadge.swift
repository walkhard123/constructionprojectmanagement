import SwiftUI

struct StatusBadge: View {
    let status: Project.ProjectStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.2))
            .foregroundColor(status.color)
            .cornerRadius(6)
    }
}

#Preview {
    HStack {
        ForEach(Project.ProjectStatus.allCases, id: \.self) { status in
            StatusBadge(status: status)
        }
    }
    .padding()
} 