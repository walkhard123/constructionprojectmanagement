import SwiftUI

struct ProjectCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Regular project
            ProjectCardView(project: PreviewData.sampleProjects[0])
                .previewLayout(.sizeThatFits)
                .padding()
            
            // Urgent project
            ProjectCardView(project: PreviewData.sampleProjects[1])
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
            
            // Completed project
            ProjectCardView(project: try! Project(
                name: "Completed Project",
                description: "This project is completed",
                progressPercentage: 100,
                status: .completed
            ))
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectListView(projectViewModel: PreviewData.mockProjectViewModel())
        }
    }
}

struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailView(
            projectViewModel: ProjectViewModel.preview,
            taskViewModel: TaskViewModel.preview,
            project: PreviewData.sampleProjects[0]
        )
    }
} 