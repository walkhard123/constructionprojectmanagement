import Foundation
import CoreData
import SwiftUI

@MainActor
class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [Task] = []
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchTasks()
    }
    
    func fetchTasks(for project: Project? = nil) {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.sortDescriptors = [
            NSSortDescriptor(key: "order", ascending: true),
            NSSortDescriptor(key: "dueDate", ascending: true)
        ]
        
        if let projectId = project?.id {
            request.predicate = NSPredicate(format: "projectId == %@", projectId as CVarArg)
        }
        
        do {
            let results = try viewContext.fetch(request)
            tasks = results.compactMap(Task.fromEntity)
            print("Fetched \(tasks.count) tasks")
            if let project = project {
                print("For project: \(project.name)")
            }
        } catch {
            print("Error fetching tasks: \(error.localizedDescription)")
            handleError(error, operation: "fetching tasks")
        }
    }
    
    func addTask(_ task: Task, to project: Project? = nil) {
        do {
            let entity = task.toEntity(in: viewContext)
            
            if let project = project {
                print("Adding task to project: \(project.name)")
                entity.setValue(project.id, forKey: "projectId")
                
                let request = NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
                request.predicate = NSPredicate(format: "id == %@", project.id as CVarArg)
                
                if let projectEntity = try viewContext.fetch(request).first {
                    entity.setValue(projectEntity, forKey: "project")
                }
            }
            
            try viewContext.save()
            print("Task saved successfully: \(task.title)")
            fetchTasks(for: project)  // Refresh tasks for the current project
        } catch {
            print("Error saving task: \(error.localizedDescription)")
            handleError(error, operation: "saving task")
        }
    }
    
    func updateTask(_ task: Task) {
        do {
            if let entity = fetchTaskEntity(by: task.id) {
                entity.setValue(task.title, forKey: "title")
                entity.setValue(task.description, forKey: "taskDescription")
                entity.setValue(task.dueDate, forKey: "dueDate")
                entity.setValue(Int16(task.priority.rawValue), forKey: "priority")
                entity.setValue(task.status.rawValue, forKey: "status")
                entity.setValue(task.isUrgent, forKey: "isUrgent")
                entity.setValue(task.projectId, forKey: "projectId")
                entity.setValue(Int16(task.order), forKey: "order")
                
                try viewContext.save()
                fetchTasks(for: projectForTask(task))
                print("Successfully updated task: \(task.title)")
            } else {
                throw TaskError.taskNotFound
            }
        } catch {
            print("Error updating task: \(error.localizedDescription)")
            handleError(error, operation: "updating task")
        }
    }
    
    func deleteTask(_ task: Task) {
        if let entity = fetchTaskEntity(by: task.id) {
            viewContext.delete(entity)
            saveContext()
        }
    }
    
    private func fetchTaskEntity(by id: UUID) -> TaskEntity? {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? viewContext.fetch(request).first
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
            fetchTasks()  // Refresh tasks after saving
        } catch {
            handleError(error, operation: "saving context")
        }
    }
    
    private func handleError(_ error: Error, operation: String) {
        let errorMessage = "Error \(operation): \(error.localizedDescription)"
        print(errorMessage)
        self.errorMessage = errorMessage
        showError = true
    }
    
    func toggleTaskCompletion(_ task: Task) {
        do {
            if let entity = fetchTaskEntity(by: task.id) {
                let newStatus = task.isCompleted ? Task.TaskStatus.inProgress : Task.TaskStatus.completed
                entity.setValue(newStatus.rawValue, forKey: "status")
                
                try viewContext.save()
                fetchTasks(for: task.projectId != nil ? projectForTask(task) : nil)
                print("Successfully toggled task completion for: \(task.title)")
            } else {
                print("Could not find task entity to toggle completion")
                throw TaskError.taskNotFound
            }
        } catch {
            print("Error toggling task completion: \(error.localizedDescription)")
            handleError(error, operation: "toggling task completion")
        }
    }
    
    private func projectForTask(_ task: Task) -> Project? {
        guard let projectId = task.projectId else { return nil }
        let request = NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
        request.predicate = NSPredicate(format: "id == %@", projectId as CVarArg)
        
        do {
            if let projectEntity = try viewContext.fetch(request).first,
               let project = Project.fromEntity(projectEntity) {
                return project
            }
        } catch {
            print("Error fetching project for task: \(error.localizedDescription)")
        }
        return nil
    }
    
    func reorderTasks(from source: IndexSet, to destination: Int, in project: Project) {
        // Create a mutable copy of the tasks array
        var updatedTasks = tasks
        updatedTasks.move(fromOffsets: source, toOffset: destination)
        
        // Update the order in Core Data
        do {
            // Fetch all task entities for this project
            let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
            request.predicate = NSPredicate(format: "projectId == %@", project.id as CVarArg)
            let entities = try viewContext.fetch(request)
            
            // Update the order for each task
            for (index, task) in updatedTasks.enumerated() {
                if let entity = entities.first(where: { ($0.value(forKey: "id") as? UUID) == task.id }) {
                    entity.setValue(index, forKey: "order")  // You'll need to add an 'order' attribute to your TaskEntity
                }
            }
            
            try viewContext.save()
            fetchTasks(for: project)  // Refresh the tasks list
            print("Successfully reordered tasks")
        } catch {
            print("Error reordering tasks: \(error.localizedDescription)")
            handleError(error, operation: "reordering tasks")
        }
    }
}

// MARK: - Custom Errors
extension TaskViewModel {
    enum TaskError: LocalizedError {
        case taskNotFound
        case projectNotFound
        
        var errorDescription: String? {
            switch self {
            case .taskNotFound:
                return "The requested task could not be found"
            case .projectNotFound:
                return "The associated project could not be found"
            }
        }
    }
}

// MARK: - Preview Helper
extension TaskViewModel {
    static var preview: TaskViewModel {
        let context = PersistenceController(inMemory: true).container.viewContext
        return TaskViewModel(context: context)
    }
} 