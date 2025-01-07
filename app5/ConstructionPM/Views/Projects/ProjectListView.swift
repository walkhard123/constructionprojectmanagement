import SwiftUI

struct ProjectListView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @StateObject private var taskViewModel = TaskViewModel(context: PersistenceController.shared.container.viewContext)
    @State private var showingNewProjectSheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProjects) { project in
                    NavigationLink {
                        ProjectDetailView(
                            projectViewModel: projectViewModel,
                            taskViewModel: taskViewModel,
                            project: project
                        )
                    } label: {
                        ProjectCardView(project: project)
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewProjectSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewProjectSheet) {
                ProjectFormView(projectViewModel: projectViewModel)
            }
            .searchable(text: $searchText, prompt: "Search projects")
        }
    }
    
    private var filteredProjects: [Project] {
        if searchText.isEmpty {
            return projectViewModel.projects
        }
        return projectViewModel.projects.filter { project in
            project.name.localizedCaseInsensitiveContains(searchText) ||
            project.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#Preview {
    NavigationView {
        ProjectListView(
            projectViewModel: ProjectViewModel(
                context: PersistenceController(inMemory: true).container.viewContext
            )
        )
    }
} 