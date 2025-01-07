import Foundation

enum DataExportError: Error {
    case encodingFailed
    case decodingFailed
    case invalidData
    case fileOperationFailed
}

class DataExportManager {
    static let shared = DataExportManager()
    
    private init() {}
    
    func exportData(projects: [Project], activities: [Activity]) throws -> Data {
        let export = ProjectExport.create(from: projects, activities: activities)
        do {
            return try JSONEncoder().encode(export)
        } catch {
            throw DataExportError.encodingFailed
        }
    }
    
    func importData(_ data: Data) throws -> (projects: [Project], activities: [Activity]) {
        do {
            let export = try JSONDecoder().decode(ProjectExport.self, from: data)
            
            let projects = try export.projects.map { projectData in
                try Project(
                    id: projectData.id,
                    name: projectData.name,
                    progressPercentage: projectData.progressPercentage,
                    tasks: projectData.tasks.map { taskData in
                        Task(
                            id: taskData.id,
                            title: taskData.title,
                            dueDate: taskData.dueDate,
                            status: Task.TaskStatus(rawValue: taskData.status) ?? .inProgress,
                            isUrgent: taskData.isUrgent
                        )
                    },
                    isUrgent: projectData.isUrgent
                )
            }
            
            let activities = export.activities.map { activityData in
                Activity(
                    id: activityData.id,
                    projectId: activityData.projectId,
                    description: activityData.description,
                    hoursSpent: activityData.hoursSpent,
                    date: activityData.date,
                    type: Activity.ActivityType(rawValue: activityData.type) ?? .other
                )
            }
            
            return (projects, activities)
        } catch {
            throw DataExportError.decodingFailed
        }
    }
} 