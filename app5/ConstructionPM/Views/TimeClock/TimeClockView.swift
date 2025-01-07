import SwiftUI
import CoreLocation

struct TimeClockView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @State private var showingProjectPicker = false
    @State private var selectedProjectId: UUID?
    @State private var isClockIn = false
    @State private var locationStatus: LocationStatus = .unknown
    
    init(projectViewModel: ProjectViewModel) {
        self.projectViewModel = projectViewModel
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Current Time
            CurrentTimeView()
            
            // Status Card
            TimeClockStatusCard(
                isClockIn: isClockIn,
                locationStatus: locationStatus,
                selectedProject: selectedProject
            )
            
            // Project Selection
            if !isClockIn {
                ProjectSelectionButton(
                    selectedProject: selectedProject,
                    action: { showingProjectPicker = true }
                )
            }
            
            Spacer()
            
            // Clock In/Out Button
            ClockInOutButton(
                isActive: isClockIn,
                locationStatus: locationStatus,
                action: handleClockAction
            )
            .disabled(!canClockInOut)
        }
        .padding()
        .navigationTitle("Time Clock")
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
    
    private var canClockInOut: Bool {
        switch locationStatus {
        case .failed, .denied:
            return false
        case .unknown, .authorized, .verifying, .verified:
            return true
        }
    }
    
    private func handleClockAction() {
        // Temporary implementation
        isClockIn.toggle()
        locationStatus = isClockIn ? .verified : .unknown
    }
}

struct TimeClockStatusCard: View {
    let isClockIn: Bool
    let locationStatus: LocationStatus
    let selectedProject: Project?
    
    var body: some View {
        VStack(spacing: 16) {
            if isClockIn {
                // Active Session Info
                Text("Clocked In")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Text(Date().formatted(date: .abbreviated, time: .standard))
                    .font(.subheadline)
                
                if let project = selectedProject {
                    Text(project.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                // Location Status
                LocationStatusView(status: locationStatus)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct LocationStatusView: View {
    let status: LocationStatus
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            Text(status.message)
                .foregroundColor(statusColor)
        }
    }
    
    private var statusIcon: String {
        switch status {
        case .unknown: return "location.slash"
        case .authorized: return "location"
        case .denied: return "location.slash.fill"
        case .verifying: return "location.circle"
        case .verified: return "location.fill"
        case .failed: return "exclamationmark.triangle"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .verified: return .green
        case .failed: return .red
        case .denied: return .red
        default: return .primary
        }
    }
}

struct ClockInOutButton: View {
    let isActive: Bool
    let locationStatus: LocationStatus
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isActive ? "Clock Out" : "Clock In")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(isActive ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

