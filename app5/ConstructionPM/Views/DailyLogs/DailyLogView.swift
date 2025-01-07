import SwiftUI

struct DailyLogView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @StateObject private var logViewModel = DailyLogViewModel()
    @State private var selectedProjectId: UUID?
    @State private var workSummary = ""
    @State private var weather: DailyLog.WeatherType = .sunny
    @State private var numberOfWorkers = 0
    @State private var hoursWorked: Double = 0
    @State private var issues = ""
    @State private var showingProjectPicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Current Date/Time
            CurrentTimeView()
            
            Form {
                // Project Selection
                Section("Project") {
                    Button(action: { showingProjectPicker = true }) {
                        HStack {
                            Text(selectedProject?.name ?? "Select Project")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Weather Selection
                Section("Weather") {
                    Picker("Weather", selection: $weather) {
                        ForEach(DailyLog.WeatherType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Work Details
                Section("Work Details") {
                    Stepper("Workers: \(numberOfWorkers)", value: $numberOfWorkers, in: 0...100)
                    
                    Stepper(value: $hoursWorked, in: 0...24, step: 0.5) {
                        Text("Hours: \(hoursWorked, specifier: "%.1f")")
                    }
                    
                    TextEditor(text: $workSummary)
                        .frame(height: 100)
                }
                
                // Issues (Optional)
                Section("Issues (Optional)") {
                    TextEditor(text: $issues)
                        .frame(height: 100)
                }
                
                // Submit Button
                Section {
                    Button(action: submitLog) {
                        Text("Submit Daily Log")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(workSummary.isEmpty || selectedProjectId == nil)
                }
            }
        }
        .navigationTitle("Daily Log")
        .sheet(isPresented: $showingProjectPicker) {
            ProjectPickerView(
                projects: projectViewModel.projects,
                selectedProjectId: $selectedProjectId
            )
        }
    }
    
    private var selectedProject: Project? {
        guard let projectId = selectedProjectId else { return nil }
        return projectViewModel.projects.first { $0.id == projectId }
    }
    
    private func submitLog() {
        let log = DailyLog(
            date: Date(),
            projectId: selectedProjectId,
            workSummary: workSummary,
            weather: weather,
            numberOfWorkers: numberOfWorkers,
            hoursWorked: hoursWorked,
            issues: issues.isEmpty ? nil : issues
        )
        
        logViewModel.addLog(log)
        resetForm()
    }
    
    private func resetForm() {
        workSummary = ""
        weather = .sunny
        numberOfWorkers = 0
        hoursWorked = 0
        issues = ""
    }
} 