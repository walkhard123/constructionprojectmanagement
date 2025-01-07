import XCTest
@testable import app5

final class ProjectTests: XCTestCase {
    func testProjectInitialization() throws {
        // Valid initialization
        let project = try Project(name: "Test Project")
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.status, .planning)
        
        // Invalid initialization - empty name
        XCTAssertThrowsError(try Project(name: "")) { error in
            XCTAssertEqual(error as? Project.ValidationError, .emptyName)
        }
        
        // Invalid initialization - invalid date range
        let pastDate = Date().addingTimeInterval(-24*60*60)
        XCTAssertThrowsError(try Project(
            name: "Test Project",
            startDate: Date(),
            dueDate: pastDate
        )) { error in
            XCTAssertEqual(error as? Project.ValidationError, .invalidDateRange)
        }
        
        // Invalid initialization - invalid progress
        XCTAssertThrowsError(try Project(
            name: "Test Project",
            progressPercentage: 101
        )) { error in
            XCTAssertEqual(error as? Project.ValidationError, .invalidProgress)
        }
    }
    
    func testProjectProgress() throws {
        var project = try Project(name: "Test Project")
        
        // Add completed task
        let completedTask = Task(
            title: "Completed Task",
            dueDate: Date(),
            status: .completed
        )
        project.addTask(completedTask)
        XCTAssertEqual(project.progressPercentage, 100)
        XCTAssertEqual(project.status, .completed)
        
        // Add in-progress task
        let inProgressTask = Task(
            title: "In Progress Task",
            dueDate: Date()
        )
        project.addTask(inProgressTask)
        XCTAssertEqual(project.progressPercentage, 50)
        XCTAssertEqual(project.status, .inProgress)
    }
    
    func testTaskDependencies() throws {
        var project = try Project(name: "Test Project")
        
        let task1 = Task(title: "Task 1", dueDate: Date())
        let task2 = Task(
            title: "Task 2",
            dueDate: Date(),
            dependencies: [task1.id]
        )
        
        project.addTask(task1)
        project.addTask(task2)
        
        XCTAssertTrue(project.validateTaskDependencies())
        
        // Test circular dependency
        var task3 = Task(
            title: "Task 3",
            dueDate: Date(),
            dependencies: [task2.id]
        )
        var task1WithDependency = task1
        task1WithDependency.dependencies = [task3.id]
        
        project.updateTask(task1WithDependency)
        project.addTask(task3)
        
        XCTAssertFalse(project.validateTaskDependencies())
    }
    
    func testProjectOverdueStatus() throws {
        // Create a project with past due date
        let pastDate = Date().addingTimeInterval(-24*60*60) // Yesterday
        var project = try Project(
            name: "Overdue Project",
            startDate: Date().addingTimeInterval(-48*60*60), // 2 days ago
            dueDate: pastDate
        )
        
        XCTAssertTrue(project.isOverdue)
        
        // Test that completed projects are not overdue
        project.status = .completed
        XCTAssertFalse(project.isOverdue)
    }
    
    func testTaskManagement() throws {
        var project = try Project(name: "Task Management Test")
        
        // Test adding tasks
        let task1 = Task(title: "Task 1", dueDate: Date())
        let task2 = Task(title: "Task 2", dueDate: Date(), isUrgent: true)
        
        project.addTask(task1)
        XCTAssertEqual(project.tasks.count, 1)
        
        project.addTask(task2)
        XCTAssertEqual(project.tasks.count, 2)
        XCTAssertEqual(project.taskStats.urgent, 1)
        
        // Test removing task
        project.removeTask(withId: task1.id)
        XCTAssertEqual(project.tasks.count, 1)
        XCTAssertEqual(project.tasks.first?.id, task2.id)
        
        // Test updating task
        var updatedTask = task2
        updatedTask.title = "Updated Task 2"
        project.updateTask(updatedTask)
        XCTAssertEqual(project.tasks.first?.title, "Updated Task 2")
    }
    
    func testTaskStatistics() throws {
        var project = try Project(name: "Statistics Test")
        
        let tasks = [
            Task(title: "Task 1", dueDate: Date(), status: .completed),
            Task(title: "Task 2", dueDate: Date(), status: .inProgress),
            Task(title: "Task 3", dueDate: Date().addingTimeInterval(-24*60*60), status: .overdue),
            Task(title: "Task 4", dueDate: Date(), status: .inProgress, isUrgent: true)
        ]
        
        tasks.forEach { project.addTask($0) }
        
        XCTAssertEqual(project.taskStats.total, 4)
        XCTAssertEqual(project.taskStats.completed, 1)
        XCTAssertEqual(project.taskStats.inProgress, 2)
        XCTAssertEqual(project.taskStats.overdue, 1)
        XCTAssertEqual(project.taskStats.urgent, 1)
        XCTAssertEqual(project.taskStats.completionPercentage, 25)
    }
} 