import SwiftUI

struct TasksView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingNewTaskSheet = false
    @State private var showingEditTaskSheet = false
    @State private var selectedTask: Task?
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        case overdue = "Overdue"
    }
    
    var body: some View {
        List {
            ForEach(filteredTasks) { task in
                TaskRowView(task: task, onToggle: {
                    withAnimation {
                        taskViewModel.toggleTaskCompletion(task)
                    }
                }, onEdit: {
                    selectedTask = task
                    showingEditTaskSheet = true
                })
            }
            .onMove(perform: moveTask)
        }
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNewTaskSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewTaskSheet) {
            TaskFormView(
                taskViewModel: taskViewModel,
                projectViewModel: projectViewModel,
                editingTask: nil
            )
        }
        .sheet(isPresented: $showingEditTaskSheet) {
            if let task = selectedTask {
                TaskFormView(
                    taskViewModel: taskViewModel,
                    projectViewModel: projectViewModel,
                    editingTask: task
                )
            }
        }
    }
    
    private var filteredTasks: [Task] {
        switch selectedFilter {
        case .all:
            return taskViewModel.tasks
        case .active:
            return taskViewModel.tasks.filter { !$0.isCompleted }
        case .completed:
            return taskViewModel.tasks.filter { $0.isCompleted }
        case .overdue:
            return taskViewModel.tasks.filter { !$0.isCompleted && $0.dueDate < Date() }
        }
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        taskViewModel.reorderTasks(from: source, to: destination, in: projectViewModel.projects.first!) // Adjust as needed
    }
} 