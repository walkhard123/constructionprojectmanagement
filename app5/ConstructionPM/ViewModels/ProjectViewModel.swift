import Foundation
import CoreData
import SwiftUI

@MainActor
class ProjectViewModel: ObservableObject {
    @Published private(set) var projects: [Project] = []
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchProjects()
    }
    
    // MARK: - CRUD Operations
    func fetchProjects() {
        let request = NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        
        do {
            let results = try viewContext.fetch(request)
            projects = results.compactMap(Project.fromEntity)
        } catch {
            handleError(error, operation: "fetching projects")
        }
    }
    
    func addProject(_ project: Project) {
        // Create and save the entity in one step
        _ = project.toEntity(in: viewContext)
        do {
            try viewContext.save()
            fetchProjects()  // Refresh the projects list after saving
        } catch {
            handleError(error, operation: "saving project")
        }
    }
    
    func updateProject(_ project: Project) {
        if let entity = fetchProjectEntity(by: project.id) {
            entity.setValue(project.name, forKey: "name")
            entity.setValue(project.description, forKey: "projectDescription")
            entity.setValue(project.address, forKey: "address")
            entity.setValue(project.projectType.rawValue, forKey: "projectType")
            entity.setValue(project.startDate, forKey: "startDate")
            entity.setValue(project.dueDate, forKey: "dueDate")
            entity.setValue(project.progressPercentage, forKey: "progressPercentage")
            entity.setValue(project.isUrgent, forKey: "isUrgent")
            entity.setValue(project.status.rawValue, forKey: "status")
            entity.setValue(Array(project.assignedTeamMembers), forKey: "assignedTeamMembers")
            
            do {
                try viewContext.save()
                fetchProjects()  // Refresh the projects list after saving
            } catch {
                handleError(error, operation: "updating project")
            }
        }
    }
    
    private func fetchProjectEntity(by id: UUID) -> ProjectEntity? {
        let request = NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? viewContext.fetch(request).first
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
            fetchProjects()  // Refresh the projects list after saving
        } catch {
            handleError(error, operation: "saving context")
        }
    }
    
    private func handleError(_ error: Error, operation: String) {
        errorMessage = "Error \(operation): \(error.localizedDescription)"
        showError = true
        print("ProjectViewModel Error: \(errorMessage ?? "")")
    }
    
    func deleteProject(_ project: Project) {
        if let entity = fetchProjectEntity(by: project.id) {
            viewContext.delete(entity)
            saveContext()
        }
    }
}

// MARK: - Custom Errors
extension ProjectViewModel {
    enum ProjectError: LocalizedError {
        case projectNotFound
        
        var errorDescription: String? {
            switch self {
            case .projectNotFound:
                return "The requested project could not be found"
            }
        }
    }
}

// MARK: - Preview Helper
extension ProjectViewModel {
    static var preview: ProjectViewModel {
        let context = PersistenceController(inMemory: true).container.viewContext
        return ProjectViewModel(context: context)
    }
} 