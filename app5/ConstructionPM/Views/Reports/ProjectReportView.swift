import SwiftUI
import Charts
import UniformTypeIdentifiers

struct ProjectReportView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var activityViewModel: ActivityViewModel
    let project: Project
    
    @State private var selectedPeriod: ProjectReport.ReportPeriod = .month
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    @State private var showingShareSheet = false
    @State private var reportPDF: Data?
    
    private var report: ProjectReport {
        let filteredActivities = filterActivities(for: selectedPeriod)
        return ProjectReport(
            project: project,
            activities: filteredActivities,
            period: selectedPeriod
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Report Header
                ReportHeader(report: report)
                
                // Period Selector
                ReportPeriodPicker(
                    selectedPeriod: $selectedPeriod,
                    customStartDate: $customStartDate,
                    customEndDate: $customEndDate
                )
                
                // Charts Section
                ReportChartsSection(report: report)
                
                // Tasks Progress
                TasksProgressSection(report: report)
                
                // Activities List
                ActivitiesListSection(activities: report.activities)
            }
            .padding()
        }
        .navigationTitle("Project Report")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: exportReport) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let reportPDF = reportPDF {
                ShareSheet(items: [reportPDF])
            }
        }
    }
    
    private func filterActivities(for period: ProjectReport.ReportPeriod) -> [Activity] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .week:
            let startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            let endDate = now
            return filterActivitiesInRange(from: startDate, to: endDate)
            
        case .month:
            let startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            let endDate = now
            return filterActivitiesInRange(from: startDate, to: endDate)
            
        case .quarter:
            let startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            let endDate = now
            return filterActivitiesInRange(from: startDate, to: endDate)
            
        case .year:
            let startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            let endDate = now
            return filterActivitiesInRange(from: startDate, to: endDate)
            
        case .custom(let from, let to):
            return filterActivitiesInRange(from: from, to: to)
        }
    }
    
    private func filterActivitiesInRange(from startDate: Date, to endDate: Date) -> [Activity] {
        activityViewModel.activities.filter { activity in
            activity.projectId == project.id &&
            activity.date >= startDate &&
            activity.date <= endDate
        }
    }
    
    private func exportReport() {
        // Generate PDF report
        let renderer = ProjectReportPDFRenderer(report: report)
        reportPDF = renderer.generatePDF()
        showingShareSheet = true
    }
}

// Helper Views...
struct ReportHeader: View {
    let report: ProjectReport
    
    var body: some View {
        VStack(spacing: 12) {
            Text(report.period.title)
                .font(.title2)
                .bold()
            
            HStack(spacing: 40) {
                StatBox(title: "Total Hours", value: String(format: "%.1f", report.totalHours))
                StatBox(title: "Completion Rate", value: String(format: "%.0f%%", report.taskCompletionRate))
                StatBox(title: "Activities", value: "\(report.activities.count)")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .bold()
        }
    }
} 