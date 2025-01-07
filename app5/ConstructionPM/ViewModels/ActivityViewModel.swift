import Foundation
import CoreData
import SwiftUI

@MainActor
class ActivityViewModel: ObservableObject {
    @Published private(set) var activities: [Activity] = []
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchActivities()
    }
    
    // MARK: - CRUD Operations
    func fetchActivities() {
        let request = NSFetchRequest<ActivityEntity>(entityName: "ActivityEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ActivityEntity.date, ascending: false)]
        
        do {
            let results = try viewContext.fetch(request)
            activities = results.compactMap(Activity.fromEntity)
        } catch {
            handleError(error, operation: "fetching activities")
        }
    }
    
    func addActivity(_ activity: Activity) {
        _ = activity.toEntity(context: viewContext)
        
        do {
            try viewContext.save()
            fetchActivities()
        } catch {
            handleError(error, operation: "adding activity")
        }
    }
    
    func deleteActivity(_ activity: Activity) {
        let request = NSFetchRequest<ActivityEntity>(entityName: "ActivityEntity")
        request.predicate = NSPredicate(format: "id == %@", activity.id as CVarArg)
        
        do {
            guard let entity = try viewContext.fetch(request).first else {
                throw ActivityError.activityNotFound
            }
            
            viewContext.delete(entity)
            try viewContext.save()
            fetchActivities()
        } catch {
            handleError(error, operation: "deleting activity")
        }
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error, operation: String) {
        let message: String
        switch error {
        case ActivityError.activityNotFound:
            message = "Activity not found"
        default:
            message = "Error \(operation): \(error.localizedDescription)"
        }
        
        errorMessage = message
        showError = true
        print("ActivityViewModel Error: \(message)")
    }
}

// MARK: - Custom Errors
extension ActivityViewModel {
    enum ActivityError: LocalizedError {
        case activityNotFound
        
        var errorDescription: String? {
            switch self {
            case .activityNotFound:
                return "The requested activity could not be found"
            }
        }
    }
}

// MARK: - Preview Helper
extension ActivityViewModel {
    static var preview: ActivityViewModel {
        let context = PersistenceController(inMemory: true).container.viewContext
        return ActivityViewModel(context: context)
    }
} 