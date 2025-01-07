import Foundation
import CoreData

@objc(UUIDSetTransformer)
final class UUIDSetTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: UUIDSetTransformer.self))
    
    override static var allowedTopLevelClasses: [AnyClass] {
        [NSSet.self, NSUUID.self, NSArray.self]
    }
    
    static func register() {
        let transformer = UUIDSetTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

class Task: Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var dueDate: Date
    var priority: Priority
    var status: TaskStatus
    var isUrgent: Bool
    var dependencies: Set<UUID>
    var projectId: UUID?
    var parentTaskId: UUID?
    var subTasks: [Task]
    var assignedMembers: Set<UUID>
    var order: Int
    
    enum Priority: Int, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        
        var label: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
    }
    
    enum TaskStatus: String, CaseIterable {
        case inProgress = "In Progress"
        case completed = "Completed"
        case overdue = "Overdue"
    }
    
    init(id: UUID = UUID(),
         title: String,
         description: String = "",
         dueDate: Date,
         priority: Priority = .medium,
         status: TaskStatus = .inProgress,
         isUrgent: Bool = false,
         dependencies: Set<UUID> = [],
         projectId: UUID? = nil,
         parentTaskId: UUID? = nil,
         subTasks: [Task] = [],
         assignedMembers: Set<UUID> = [],
         order: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.priority = priority
        self.status = status
        self.isUrgent = isUrgent
        self.dependencies = dependencies
        self.projectId = projectId
        self.parentTaskId = parentTaskId
        self.subTasks = subTasks
        self.assignedMembers = assignedMembers
        self.order = order
    }
    
    init(title: String, projectId: UUID? = nil) {
        self.id = UUID()
        self.title = title
        self.description = ""
        self.dueDate = Date().addingTimeInterval(24*60*60) // Default to tomorrow
        self.priority = .medium
        self.status = .inProgress
        self.isUrgent = false
        self.dependencies = []
        self.projectId = projectId
        self.parentTaskId = nil
        self.subTasks = []
        self.assignedMembers = []
        self.order = 0
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - CoreData Conversion
    func toEntity(in context: NSManagedObjectContext) -> TaskEntity {
        let entity = TaskEntity(context: context)
        entity.setValue(id, forKey: "id")
        entity.setValue(title, forKey: "title")
        entity.setValue(description, forKey: "taskDescription")
        entity.setValue(dueDate, forKey: "dueDate")
        entity.setValue(Int16(priority.rawValue), forKey: "priority")
        entity.setValue(status.rawValue, forKey: "status")
        entity.setValue(isUrgent, forKey: "isUrgent")
        entity.setValue(projectId, forKey: "projectId")
        entity.setValue(Int16(order), forKey: "order")
        return entity
    }
    
    static func fromEntity(_ entity: TaskEntity) -> Task? {
        guard let id = entity.value(forKey: "id") as? UUID,
              let title = entity.value(forKey: "title") as? String,
              let dueDate = entity.value(forKey: "dueDate") as? Date,
              let statusString = entity.value(forKey: "status") as? String,
              let status = TaskStatus(rawValue: statusString)
        else { return nil }
        
        return Task(
            id: id,
            title: title,
            description: entity.value(forKey: "taskDescription") as? String ?? "",
            dueDate: dueDate,
            priority: Priority(rawValue: Int(entity.value(forKey: "priority") as? Int16 ?? 1)) ?? .medium,
            status: status,
            isUrgent: entity.value(forKey: "isUrgent") as? Bool ?? false,
            dependencies: [],
            projectId: entity.value(forKey: "projectId") as? UUID,
            parentTaskId: nil,
            subTasks: [],
            assignedMembers: [],
            order: Int(entity.value(forKey: "order") as? Int16 ?? 0)
        )
    }
} 