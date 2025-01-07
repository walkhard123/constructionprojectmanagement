import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var priority = Task.Priority.medium
    @State private var isUrgent = false
    @State private var selectedProject: Project?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let editingTask: Task?
    let initialProject: Project?
    
    init(taskViewModel: TaskViewModel, 
         projectViewModel: ProjectViewModel, 
         editingTask: Task? = nil,
         initialProject: Project? = nil) {
        self.taskViewModel = taskViewModel
        self.projectViewModel = projectViewModel
        self.editingTask = editingTask
        self.initialProject = initialProject
        _selectedProject = State(initialValue: initialProject)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section {
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.label).tag(priority)
                        }
                    }
                    Toggle("Mark as Urgent", isOn: $isUrgent)
                }
                
                Section(header: Text("Project")) {
                    Picker("Project", selection: $selectedProject) {
                        Text("None").tag(nil as Project?)
                        ForEach(projectViewModel.projects) { project in
                            Text(project.name).tag(project as Project?)
                        }
                    }
                }
            }
            .navigationTitle(editingTask == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingTask == nil ? "Create" : "Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveTask() {
        print("Starting task save...")
        let task = Task(
            id: editingTask?.id ?? UUID(),
            title: title,
            description: description,
            dueDate: dueDate,
            priority: priority,
            status: .inProgress,
            isUrgent: isUrgent,
            dependencies: [],
            projectId: selectedProject?.id,
            parentTaskId: nil,
            subTasks: [],
            assignedMembers: []
        )
        print("Task created: \(task.title)")
        
        if editingTask != nil {
            print("Updating existing task...")
            taskViewModel.updateTask(task)
        } else {
            print("Creating new task...")
            taskViewModel.addTask(task, to: selectedProject)
        }
        print("Task saved successfully")
        
        dismiss()
    }
} 