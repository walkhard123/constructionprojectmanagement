import XCTest
@testable import ConstructionPM

final class CoreFunctionalityTests: XCTestCase {
    var projectViewModel: ProjectViewModel!
    var taskViewModel: TaskViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController(inMemory: true).container.viewContext
        projectViewModel = ProjectViewModel(context: context)
        taskViewModel = TaskViewModel(context: context)
    }
    
    // MARK: - Project Tests
    func testProjectLifecycle() throws {
        // Create
        let project = try Project(
            name: "Test Project",
            description: "Test Description",
            startDate: Date(),
            dueDate: Date().addingTimeInterval(7*24*60*60)
        )
        projectViewModel.addProject(project)
        XCTAssertEqual(projectViewModel.projects.count, 1)
        
        // Update
        var updatedProject = project
        updatedProject.name = "Updated Project"
        projectViewModel.updateProject(updatedProject)
        XCTAssertEqual(projectViewModel.projects.first?.name, "Updated Project")
        
        // Delete
        projectViewModel.deleteProject(project)
        XCTAssertTrue(projectViewModel.projects.isEmpty)
    }
    
    // MARK: - Task Tests
    func testTaskManagement() throws {
        let project = try Project(name: "Test Project")
        projectViewModel.addProject(project)
        
        // Add Task
        let task = Task(
            title: "Test Task",
            dueDate: Date().addingTimeInterval(24*60*60)
        )
        taskViewModel.addTask(task, to: project)
        
        // Verify Project Update
        let updatedProject = projectViewModel.projects.first
        XCTAssertEqual(updatedProject?.tasks.count, 1)
        
        // Update Task Status
        var completedTask = task
        completedTask.status = .completed
        taskViewModel.updateTask(completedTask, in: project)
        
        // Verify Progress Update
        let finalProject = projectViewModel.projects.first
        XCTAssertEqual(finalProject?.progressPercentage, 100)
    }
    
    // MARK: - Progress Calculation Tests
    func testProjectProgress() throws {
        var project = try Project(name: "Progress Test")
        
        // Add mixed status tasks
        let tasks = [
            Task(title: "Task 1", dueDate: Date(), status: .completed),
            Task(title: "Task 2", dueDate: Date(), status: .inProgress),
            Task(title: "Task 3", dueDate: Date(), status: .inProgress)
        ]
        
        tasks.forEach { project.addTask($0) }
        XCTAssertEqual(project.progressPercentage, 33.33, accuracy: 0.01)
    }
    
    // MARK: - Date Handling Tests
    func testProjectDates() throws {
        let startDate = Date()
        let dueDate = startDate.addingTimeInterval(5*24*60*60) // 5 days
        
        let project = try Project(
            name: "Date Test",
            startDate: startDate,
            dueDate: dueDate
        )
        
        XCTAssertEqual(project.daysRemaining, 5)
        XCTAssertFalse(project.isOverdue)
        
        // Test overdue project
        let overdueProject = try Project(
            name: "Overdue Test",
            startDate: Date().addingTimeInterval(-10*24*60*60),
            dueDate: Date().addingTimeInterval(-1*24*60*60)
        )
        
        XCTAssertTrue(overdueProject.isOverdue)
    }
} 