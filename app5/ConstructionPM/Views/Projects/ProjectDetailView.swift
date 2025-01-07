import SwiftUI

struct ProjectDetailView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var taskViewModel: TaskViewModel
    let project: Project
    @State private var showingEditSheet = false
    @State private var showingNewTaskSheet = false
    @State private var showingDeleteAlert = false
    @State private var selectedFilter: TaskFilter = .all
    
    var body: some View {
        ProjectContentView(
            project: project,
            taskViewModel: taskViewModel,
            projectViewModel: projectViewModel,
            selectedFilter: $selectedFilter
        )
        .navigationTitle(project.name)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingEditSheet) {
            ProjectFormView(projectViewModel: projectViewModel, editingProject: project)
        }
        .sheet(isPresented: $showingNewTaskSheet) {
            TaskFormView(
                taskViewModel: taskViewModel,
                projectViewModel: projectViewModel,
                editingTask: nil,
                initialProject: project
            )
        }
        .alert(isPresented: $showingDeleteAlert) {
            deleteAlert
        }
        .onAppear {
            taskViewModel.fetchTasks(for: project)
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNewTaskSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                }
            }
        }
    }
    
    private var deleteAlert: Alert {
        Alert(
            title: Text("Delete Project?"),
            message: Text("This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
                projectViewModel.deleteProject(project)
            },
            secondaryButton: .cancel()
        )
    }
}

// Break out the main content into a separate view
private struct ProjectContentView: View {
    let project: Project
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    @Binding var selectedFilter: TaskFilter
    
    private var filteredTasks: [Task] {
        taskViewModel.tasks.filter { task in
            task.projectId == project.id
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Project Details
                Group {
                    ProjectDetailsSection(project: project)
                }
                .padding(.horizontal)
                
                // Tasks Section
                TasksContentSection(
                    tasks: filteredTasks,
                    taskViewModel: taskViewModel,
                    projectViewModel: projectViewModel,
                    selectedFilter: $selectedFilter
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

private struct TasksContentSection: View {
    let tasks: [Task]
    let taskViewModel: TaskViewModel
    let projectViewModel: ProjectViewModel
    @Binding var selectedFilter: TaskFilter
    @State private var editingTask: Task?
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            TasksSectionHeader(selectedFilter: $selectedFilter)
                .padding(.bottom, 8)
            
            ForEach(tasks) { taskItem in
                TaskRowView(
                    task: taskItem,
                    onToggle: { toggleCompletion(taskItem) },
                    onEdit: {
                        editingTask = taskItem
                        showingEditSheet = true
                    }
                )
                if taskItem.id != tasks.last?.id {
                    Divider()
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let task = editingTask {
                TaskFormView(
                    taskViewModel: taskViewModel,
                    projectViewModel: projectViewModel,
                    editingTask: task,
                    initialProject: projectViewModel.projects.first { $0.id == task.projectId }
                )
            }
        }
    }
    
    private func toggleCompletion(_ taskItem: Task) {
        _Concurrency.Task { @MainActor in
            taskViewModel.toggleTaskCompletion(taskItem)
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController(inMemory: true).container.viewContext
    let date = Date()
    let sampleProject = try! Project(
        id: UUID(),
        name: "Sample Project",
        description: "A sample project",
        address: "123 Main St",
        projectType: .house,
        startDate: date,
        dueDate: date.addingTimeInterval(7*24*60*60),
        progressPercentage: 50,
        tasks: [],
        isUrgent: true,
        status: .inProgress,
        assignedTeamMembers: Set<UUID>()
    )
    
    return NavigationView {
        ProjectDetailView(
            projectViewModel: ProjectViewModel(context: context),
            taskViewModel: TaskViewModel(context: context),
            project: sampleProject
        )
    }
} 

