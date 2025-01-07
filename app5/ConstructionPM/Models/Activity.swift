import Foundation
import CoreData

@objc(ActivityEntity)
public class ActivityEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var projectId: UUID?
    @NSManaged public var activityDescription: String?
    @NSManaged public var hoursSpent: Double
    @NSManaged public var date: Date?
    @NSManaged public var type: String?
}

struct Activity: Identifiable {
    let id: UUID
    let projectId: UUID
    let description: String
    let hoursSpent: Double
    let date: Date
    let type: ActivityType
    
    enum ActivityType: String, CaseIterable {
        case planning = "Planning"
        case development = "Development"
        case testing = "Testing"
        case meeting = "Meeting"
        case other = "Other"
    }
}

extension Activity {
    static func fromEntity(_ entity: ActivityEntity) -> Activity? {
        guard let id = entity.id,
              let projectId = entity.projectId,
              let type = entity.type,
              let activityType = ActivityType(rawValue: type)
        else { return nil }
        
        return Activity(
            id: id,
            projectId: projectId,
            description: entity.activityDescription ?? "",
            hoursSpent: entity.hoursSpent,
            date: entity.date ?? Date(),
            type: activityType
        )
    }
    
    func toEntity(context: NSManagedObjectContext) -> ActivityEntity {
        let entity = ActivityEntity(context: context)
        entity.id = id
        entity.projectId = projectId
        entity.activityDescription = description
        entity.hoursSpent = hoursSpent
        entity.date = date
        entity.type = type.rawValue
        return entity
    }
} 