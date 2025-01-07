import SwiftUI

struct ProjectFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var projectViewModel: ProjectViewModel
    @State private var name = ""
    @State private var description = ""
    @State private var address = ""
    @State private var projectType = Project.ProjectType.house
    @State private var startDate = Date()
    @State private var dueDate = Date().addingTimeInterval(30*24*60*60)
    @State private var isUrgent = false
    @State private var status = Project.ProjectStatus.planning
    @State private var selectedTeamMembers = Set<UUID>()
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccessAlert = false
    
    let editingProject: Project?
    
    init(projectViewModel: ProjectViewModel, editingProject: Project? = nil) {
        self.projectViewModel = projectViewModel
        self.editingProject = editingProject
        
        if let project = editingProject {
            _name = State(initialValue: project.name)
            _description = State(initialValue: project.description)
            _address = State(initialValue: project.address)
            _projectType = State(initialValue: project.projectType)
            _startDate = State(initialValue: project.startDate)
            _dueDate = State(initialValue: project.dueDate)
            _isUrgent = State(initialValue: project.isUrgent)
            _status = State(initialValue: project.status)
            _selectedTeamMembers = State(initialValue: Set(project.assignedTeamMembers))
        }
    }
    
    private func clearForm() {
        name = ""
        description = ""
        address = ""
        projectType = .house
        startDate = Date()
        dueDate = Date().addingTimeInterval(30*24*60*60)
        isUrgent = false
        status = .planning
        selectedTeamMembers.removeAll()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project Name", text: $name)
                    TextField("Address", text: $address)
                    Picker("Type", selection: $projectType) {
                        ForEach(Project.ProjectType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section {
                    Picker("Status", selection: $status) {
                        ForEach(Project.ProjectStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    Toggle("Mark as Urgent", isOn: $isUrgent)
                }
                
                Section(header: Text("Team Members")) {
                    TeamMemberSelectionView(selectedMembers: $selectedTeamMembers)
                }
            }
            .navigationTitle(editingProject == nil ? "New Project" : "Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingProject == nil ? "Create" : "Save") {
                        saveProject()
                    }
                    .disabled(name.isEmpty || address.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("Add Another") { }
                Button("Done") { dismiss() }
            } message: {
                Text("Project created successfully!")
            }
        }
    }
    
    private func saveProject() {
        do {
            let project = try Project(
                id: editingProject?.id ?? UUID(),
                name: name,
                description: description,
                address: address,
                projectType: projectType,
                startDate: startDate,
                dueDate: dueDate,
                progressPercentage: editingProject?.progressPercentage ?? 0,
                tasks: editingProject?.tasks ?? [],
                isUrgent: isUrgent,
                status: status,
                assignedTeamMembers: selectedTeamMembers
            )
            
            if editingProject != nil {
                projectViewModel.updateProject(project)
                dismiss()
            } else {
                projectViewModel.addProject(project)
                showingSuccessAlert = true
                clearForm()
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
} 