import Foundation

struct ProjectExport: Codable {
    let projects: [ProjectData]
    let activities: [ActivityData]
    let exportDate: Date
    
    struct ProjectData: Codable {
        let id: UUID
        let name: String
        let progressPercentage: Double
        let isUrgent: Bool
        let tasks: [TaskData]
    }
    
    struct TaskData: Codable {
        let id: UUID
        let title: String
        let dueDate: Date
        let status: String
        let isUrgent: Bool
    }
    
    struct ActivityData: Codable {
        let id: UUID
        let projectId: UUID
        let description: String
        let hoursSpent: Double
        let date: Date
        let type: String
    }
}

extension ProjectExport {
    static func create(from projects: [Project], activities: [Activity]) -> ProjectExport {
        let projectData = projects.map { project in
            ProjectData(
                id: project.id,
                name: project.name,
                progressPercentage: project.progressPercentage,
                isUrgent: project.isUrgent,
                tasks: project.tasks.map { task in
                    TaskData(
                        id: task.id,
                        title: task.title,
                        dueDate: task.dueDate,
                        status: task.status.rawValue,
                        isUrgent: task.isUrgent
                    )
                }
            )
        }
        
        let activityData = activities.map { activity in
            ActivityData(
                id: activity.id,
                projectId: activity.projectId,
                description: activity.description,
                hoursSpent: activity.hoursSpent,
                date: activity.date,
                type: activity.type.rawValue
            )
        }
        
        return ProjectExport(
            projects: projectData,
            activities: activityData,
            exportDate: Date()
        )
    }
} 