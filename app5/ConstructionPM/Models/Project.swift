import Foundation
import CoreData
import SwiftUI

class Project: Identifiable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var address: String
    var projectType: ProjectType
    var startDate: Date
    var dueDate: Date
    var progressPercentage: Double
    var tasks: [Task]
    var isUrgent: Bool
    var status: ProjectStatus
    var assignedTeamMembers: Set<UUID> // Store member IDs
    
    enum ProjectStatus: String, CaseIterable {
        case planning = "Planning"
        case inProgress = "In Progress"
        case onHold = "On Hold"
        case completed = "Completed"
        
        var color: Color {
            switch self {
            case .planning: return .blue
            case .inProgress: return .green
            case .onHold: return .orange
            case .completed: return .gray
            }
        }
    }
    
    enum ProjectType: String, CaseIterable {
        case house = "House"
        case duplex = "Duplex"
        case townhouse = "Townhouse"
        case commercial = "Commercial"
        case other = "Other"
    }
    
    init(id: UUID = UUID(), 
         name: String, 
         description: String = "",
         address: String = "",
         projectType: ProjectType = .other,
         startDate: Date = Date(),
         dueDate: Date = Date().addingTimeInterval(30*24*60*60),
         progressPercentage: Double = 0,
         tasks: [Task] = [],
         isUrgent: Bool = false,
         status: ProjectStatus = .planning,
         assignedTeamMembers: Set<UUID> = []) throws {
        
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyName
        }
        
        guard dueDate > startDate else {
            throw ValidationError.invalidDateRange
        }
        
        guard progressPercentage >= 0 && progressPercentage <= 100 else {
            throw ValidationError.invalidProgress
        }
        
        guard !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyAddress
        }
        
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.projectType = projectType
        self.startDate = startDate
        self.dueDate = dueDate
        self.progressPercentage = progressPercentage
        self.tasks = tasks
        self.isUrgent = isUrgent
        self.status = status
        self.assignedTeamMembers = assignedTeamMembers
    }
    
    // MARK: - CoreData Conversion
    static func fromEntity(_ entity: ProjectEntity) -> Project? {
        guard let id = entity.value(forKey: "id") as? UUID,
              let name = entity.value(forKey: "name") as? String,
              let startDate = entity.value(forKey: "startDate") as? Date,
              let dueDate = entity.value(forKey: "dueDate") as? Date,
              let statusString = entity.value(forKey: "status") as? String,
              let status = ProjectStatus(rawValue: statusString)
        else { return nil }
        
        let tasks = (entity.value(forKey: "tasks") as? NSSet)?.allObjects as? [TaskEntity] ?? []
        let mappedTasks = tasks.compactMap(Task.fromEntity)
        
        let teamMembers = entity.value(forKey: "assignedTeamMembers") as? [UUID] ?? []
        
        return try? Project(
            id: id,
            name: name,
            description: entity.value(forKey: "projectDescription") as? String ?? "",
            address: entity.value(forKey: "address") as? String ?? "",
            projectType: ProjectType(rawValue: entity.value(forKey: "projectType") as? String ?? "other") ?? .other,
            startDate: startDate,
            dueDate: dueDate,
            progressPercentage: entity.value(forKey: "progressPercentage") as? Double ?? 0,
            tasks: mappedTasks,
            isUrgent: entity.value(forKey: "isUrgent") as? Bool ?? false,
            status: status,
            assignedTeamMembers: Set(teamMembers)
        )
    }
    
    func toEntity(in context: NSManagedObjectContext) -> ProjectEntity {
        let entity = ProjectEntity(context: context)
        entity.setValue(id, forKey: "id")
        entity.setValue(name, forKey: "name")
        entity.setValue(description, forKey: "projectDescription")
        entity.setValue(address, forKey: "address")
        entity.setValue(projectType.rawValue, forKey: "projectType")
        entity.setValue(startDate, forKey: "startDate")
        entity.setValue(dueDate, forKey: "dueDate")
        entity.setValue(progressPercentage, forKey: "progressPercentage")
        entity.setValue(isUrgent, forKey: "isUrgent")
        entity.setValue(status.rawValue, forKey: "status")
        entity.setValue(Array(assignedTeamMembers), forKey: "assignedTeamMembers")
        return entity
    }
    
    // MARK: - Hashable
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var taskStats: [Task.TaskStatus: Int] {
        Dictionary(grouping: tasks, by: { $0.status })
            .mapValues { $0.count }
    }

    var isOverdue: Bool {
        return dueDate < Date() && !tasks.allSatisfy { $0.isCompleted }
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        return calendar.dateComponents([.day], from: now, to: dueDate).day ?? 0
    }

    var overdueTasksCount: Int {
        tasks.filter { task in
            !task.isCompleted && task.dueDate < Date()
        }.count
    }

    var isCompleted: Bool {
        status == .completed
    }
}

// MARK: - Validation
extension Project {
    enum ValidationError: LocalizedError {
        case emptyName
        case emptyAddress
        case invalidDateRange
        case invalidProgress
        
        var errorDescription: String? {
            switch self {
            case .emptyName:
                return "Project name cannot be empty"
            case .emptyAddress:
                return "Project address cannot be empty"
            case .invalidDateRange:
                return "Due date must be after start date"
            case .invalidProgress:
                return "Progress must be between 0 and 100"
            }
        }
    }
} 
