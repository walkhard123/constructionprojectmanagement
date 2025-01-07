import Foundation
import CoreData

// MARK: - Task Entity
@objc(TaskEntity)
final public class TaskEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String?
    @NSManaged public var dueDate: Date
    @NSManaged public var priority: Int16
    @NSManaged public var status: String
    @NSManaged public var isUrgent: Bool
    @NSManaged public var projectId: UUID?
    @NSManaged public var order: Int16
    @NSManaged public var project: ProjectEntity?
}

// MARK: - Project Entity
@objc(ProjectEntity)
final public class ProjectEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var projectDescription: String?
    @NSManaged public var address: String
    @NSManaged public var projectType: String
    @NSManaged public var startDate: Date
    @NSManaged public var dueDate: Date
    @NSManaged public var progressPercentage: Double
    @NSManaged public var isUrgent: Bool
    @NSManaged public var status: String
    @NSManaged public var tasks: NSSet?
}

// MARK: - Task Entity Extensions
extension TaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: String(describing: TaskEntity.self))
    }
    
    static var entityName: String {
        return String(describing: TaskEntity.self)
    }
}

// MARK: - Project Entity Extensions
extension ProjectEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectEntity> {
        return NSFetchRequest<ProjectEntity>(entityName: String(describing: ProjectEntity.self))
    }
    
    static var entityName: String {
        return String(describing: ProjectEntity.self)
    }
    
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskEntity)
    
    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskEntity)
    
    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)
    
    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
} 