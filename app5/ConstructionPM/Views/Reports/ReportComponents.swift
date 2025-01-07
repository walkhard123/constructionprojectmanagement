import SwiftUI
import Charts

struct ReportPeriodPicker: View {
    @Binding var selectedPeriod: ProjectReport.ReportPeriod
    @Binding var customStartDate: Date
    @Binding var customEndDate: Date
    
    var body: some View {
        VStack(spacing: 12) {
            Picker("Report Period", selection: $selectedPeriod) {
                Text("Week").tag(ProjectReport.ReportPeriod.week)
                Text("Month").tag(ProjectReport.ReportPeriod.month)
                Text("Year").tag(ProjectReport.ReportPeriod.year)
                Text("Custom").tag(ProjectReport.ReportPeriod.custom(from: customStartDate, to: customEndDate))
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if case .custom = selectedPeriod {
                HStack {
                    DatePicker("From", selection: $customStartDate, displayedComponents: .date)
                    DatePicker("To", selection: $customEndDate, displayedComponents: .date)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ReportChartsSection: View {
    let report: ProjectReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Distribution")
                .font(.headline)
            
            Chart {
                ForEach(Array(report.hoursPerType), id: \.key) { type, hours in
                    SectorMark(
                        angle: .value("Hours", hours),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Type", type.rawValue))
                }
            }
            .frame(height: 200)
            
            // Legend
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Array(report.hoursPerType), id: \.key) { type, hours in
                    HStack {
                        Circle()
                            .fill(Color.blue.opacity(0.8))
                            .frame(width: 8, height: 8)
                        Text(type.rawValue)
                            .font(.caption)
                        Text(String(format: "%.1f hrs", hours))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct TasksProgressSection: View {
    let report: ProjectReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tasks Progress")
                .font(.headline)
            
            VStack(spacing: 12) {
                ProgressView(value: report.taskCompletionRate, total: 100)
                    .tint(.green)
                
                HStack {
                    Text("Completed Tasks:")
                        .foregroundColor(.secondary)
                    Text("\(report.completedTasksCount) of \(report.project.tasks.count)")
                        .bold()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ActivitiesListSection: View {
    let activities: [Activity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Log")
                .font(.headline)
            
            ForEach(activities.sorted(by: { $0.date > $1.date })) { activity in
                ActivityLogRow(activity: activity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ActivityLogRow: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(activity.type.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(activity.description)
                .font(.body)
            
            Text("\(activity.hoursSpent, specifier: "%.1f") hours")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
        }
    }
} 