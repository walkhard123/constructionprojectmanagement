import SwiftUI
import Charts

struct ProjectStatusChartSection: View {
    let analytics: ProjectAnalytics
    
    private var projectStatusData: [(status: String, count: Int)] {
        [
            ("Not Started", analytics.projects.filter { $0.tasks.isEmpty }.count),
            ("In Progress", analytics.projects.filter { !$0.tasks.isEmpty && !$0.isCompleted }.count),
            ("Completed", analytics.projects.filter { $0.isCompleted }.count)
        ]
    }
    
    private var completionPercentage: Double {
        let completed = analytics.projects.filter { $0.isCompleted }.count
        return analytics.projects.isEmpty ? 0 : Double(completed) / Double(analytics.projects.count) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Status")
                .font(.headline)
            
            Text("\(Int(completionPercentage))% Complete")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Chart {
                ForEach(projectStatusData, id: \.status) { item in
                    BarMark(
                        x: .value("Status", item.status),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(by: .value("Status", item.status))
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ActivityDistributionSection: View {
    let analytics: ProjectAnalytics
    
    private var activityData: [(type: Activity.ActivityType, hours: Double)] {
        Activity.ActivityType.allCases.map { type in
            let hours = analytics.activities
                .filter { $0.type == type && analytics.isInTimeFrame($0.date) }
                .reduce(0) { $0 + $1.hoursSpent }
            return (type, hours)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Distribution")
                .font(.headline)
            
            Chart {
                ForEach(activityData, id: \.type) { item in
                    SectorMark(
                        angle: .value("Hours", item.hours),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Type", item.type.rawValue))
                }
            }
            .frame(height: 200)
            
            // Legend
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(activityData, id: \.type) { item in
                    HStack {
                        Circle()
                            .fill(Color.blue.opacity(0.8))
                            .frame(width: 8, height: 8)
                        Text(item.type.rawValue)
                            .font(.caption)
                        Text(String(format: "%.1f hrs", item.hours))
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

struct TaskCompletionTrendSection: View {
    let analytics: ProjectAnalytics
    
    private var trendData: [(date: Date, completion: Double)] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        return analytics.activities
            .filter { activity in
                activity.date >= startDate && activity.date <= now
            }
            .reduce(into: [:]) { result, activity in
                let dateKey = calendar.startOfDay(for: activity.date)
                result[dateKey, default: 0] += activity.hoursSpent
            }
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Completion Trend")
                .font(.headline)
            
            Chart {
                ForEach(trendData, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Completion", item.completion)
                    )
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Completion", item.completion)
                    )
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisValueLabel("\(value.as(Double.self)?.formatted(.percent) ?? "")")
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(value.as(Date.self)?.formatted(.dateTime.weekday(.abbreviated)) ?? "")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct TaskProgressChartSection: View {
    let analytics: ProjectAnalytics
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    
    private var filteredActivities: [Activity] {
        analytics.activities.filter { activity in
            activity.date >= startDate && activity.date <= endDate
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Progress")
                .font(.headline)
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            
            Chart {
                ForEach(filteredActivities) { activity in
                    BarMark(
                        x: .value("Date", activity.date),
                        y: .value("Hours", activity.hoursSpent)
                    )
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(value.as(Date.self)?.formatted(.dateTime.month(.abbreviated).day()) ?? "")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
} 