import SwiftUI

struct DashboardView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var taskViewModel: TaskViewModel
    @State private var selectedStatusFilter: Project.ProjectStatus?
    @State private var showingUrgentOnly = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Status Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterButton(
                                title: "All",
                                isSelected: selectedStatusFilter == nil
                            ) {
                                selectedStatusFilter = nil
                            }
                            
                            ForEach(Project.ProjectStatus.allCases, id: \.self) { status in
                                FilterButton(
                                    title: status.rawValue,
                                    isSelected: selectedStatusFilter == status
                                ) {
                                    selectedStatusFilter = status
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Urgent Toggle
                    Toggle("Show Urgent Only", isOn: $showingUrgentOnly)
                        .padding(.horizontal)
                    
                    // Projects Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
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
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Dashboard")
        }
    }
    
    private var filteredProjects: [Project] {
        var projects = projectViewModel.projects
        
        if let status = selectedStatusFilter {
            projects = projects.filter { $0.status == status }
        }
        
        if showingUrgentOnly {
            projects = projects.filter { $0.isUrgent }
        }
        
        return projects
    }
} 
