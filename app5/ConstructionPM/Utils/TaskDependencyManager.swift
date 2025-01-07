import Foundation

class TaskDependencyManager {
    static let shared = TaskDependencyManager()
    
    private init() {}
    
    func addDependency(task: Task, dependsOn dependencyTask: Task) -> Task {
        let updatedTask = task
        updatedTask.dependencies.insert(dependencyTask.id)
        return updatedTask
    }
    
    func removeDependency(task: Task, dependency dependencyId: UUID) -> Task {
        let updatedTask = task
        updatedTask.dependencies.remove(dependencyId)
        return updatedTask
    }
    
    func validateDependencies(tasks: [Task]) -> Bool {
        // Check for circular dependencies
        for task in tasks {
            if hasCyclicDependency(taskId: task.id, dependencies: task.dependencies, allTasks: tasks) {
                return false
            }
        }
        return true
    }
    
    private func hasCyclicDependency(taskId: UUID, dependencies: Set<UUID>, allTasks: [Task], visited: Set<UUID> = []) -> Bool {
        if visited.contains(taskId) {
            return true
        }
        
        var visited = visited
        visited.insert(taskId)
        
        for dependencyId in dependencies {
            if let dependencyTask = allTasks.first(where: { $0.id == dependencyId }) {
                if hasCyclicDependency(taskId: dependencyId, dependencies: dependencyTask.dependencies, allTasks: allTasks, visited: visited) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func calculateEarliestStartDate(for task: Task, allTasks: [Task]) -> Date {
        guard !task.dependencies.isEmpty else { return task.dueDate }
        
        return task.dependencies
            .compactMap { dependencyId in
                allTasks.first(where: { $0.id == dependencyId })?.dueDate
            }
            .max() ?? task.dueDate
    }
} 