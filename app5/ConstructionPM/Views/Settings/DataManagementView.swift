import SwiftUI
import UniformTypeIdentifiers

struct DataManagementView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var activityViewModel: ActivityViewModel
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingImportError = false
    @State private var importError: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Data Export")) {
                Button(action: exportData) {
                    Label("Export All Data", systemImage: "square.and.arrow.up")
                }
            }
            
            Section(header: Text("Data Import")) {
                Button(action: { showingImportPicker = true }) {
                    Label("Import Data", systemImage: "square.and.arrow.down")
                }
            }
            
            Section(header: Text("Data Statistics"), footer: Text("Last sync: \(Date().formatted())")) {
                HStack {
                    Text("Projects")
                    Spacer()
                    Text("\(projectViewModel.projects.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Activities")
                    Spacer()
                    Text("\(activityViewModel.activities.count)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Data Management")
        .sheet(isPresented: $showingExportSheet) {
            if let exportData = try? DataExportManager.shared.exportData(
                projects: projectViewModel.projects,
                activities: activityViewModel.activities
            ) {
                ShareSheet(items: [exportData])
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [UTType.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .alert("Import Error", isPresented: $showingImportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importError)
        }
    }
    
    private func exportData() {
        showingExportSheet = true
    }
    
    private func handleImport(_ result: Result<[URL], Error>) {
        do {
            guard let selectedFile = try result.get().first else { return }
            
            if selectedFile.startAccessingSecurityScopedResource() {
                defer { selectedFile.stopAccessingSecurityScopedResource() }
                
                let data = try Data(contentsOf: selectedFile)
                let importedData = try DataExportManager.shared.importData(data)
                
                // Import data using proper methods
                for project in importedData.projects {
                    projectViewModel.addProject(project)
                }
                for activity in importedData.activities {
                    activityViewModel.addActivity(activity)
                }
            }
        } catch {
            importError = error.localizedDescription
            showingImportError = true
        }
    }
} 