import Foundation

struct PreviewData {
    static var sampleProjects: [Project] {
        do {
            return [
                try Project(
                    name: "Office Renovation",
                    description: "Complete renovation of main office space",
                    startDate: Date(),
                    dueDate: Date().addingTimeInterval(60*24*60*60),
                    progressPercentage: 35,
                    tasks: [
                        Task(
                            title: "Design Planning",
                            dueDate: Date().addingTimeInterval(7*24*60*60),
                            status: .completed
                        ),
                        Task(
                            title: "Material Procurement",
                            dueDate: Date().addingTimeInterval(14*24*60*60),
                            status: .inProgress,
                            isUrgent: true
                        )
                    ],
                    isUrgent: true
                )
            ]
        } catch {
            fatalError("Error creating preview project: \(error)")
        }
    }
    
    @MainActor
    static func mockProjectViewModel() -> ProjectViewModel {
        let viewModel = ProjectViewModel(context: PersistenceController.preview.container.viewContext)
        for project in sampleProjects {
            viewModel.addProject(project)
        }
        return viewModel
    }
    
    @MainActor
    static func mockTaskViewModel() -> TaskViewModel {
        let viewModel = TaskViewModel(context: PersistenceController.preview.container.viewContext)
        if let project = sampleProjects.first {
            for task in project.tasks {
                viewModel.addTask(task, to: project)
            }
        }
        return viewModel
    }
}

// MARK: - Preview Providers
extension Project {
    static var preview: Project {
        do {
            return try Project(
                name: "Sample Project",
                description: "This is a sample project for preview",
                tasks: [
                    Task(title: "Task 1", dueDate: Date(), status: .completed),
                    Task(title: "Task 2", dueDate: Date(), isUrgent: true)
                ],
                isUrgent: true
            )
        } catch {
            fatalError("Error creating preview project: \(error)")
        }
    }
}

extension Task {
    static var preview: Task {
        Task(
            title: "Sample Task",
            dueDate: Date().addingTimeInterval(7*24*60*60),
            status: .inProgress,
            isUrgent: true
        )
    }
}

extension Activity {
    static var preview: Activity {
        Activity(
            id: UUID(),
            projectId: Project.preview.id,
            description: "Sample activity",
            hoursSpent: 2.0,
            date: Date(),
            type: .development
        )
    }
} 