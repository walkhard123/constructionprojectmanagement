import SwiftUI
import Charts

struct DashboardAnalyticsView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var activityViewModel: ActivityViewModel
    @State private var selectedTimeFrame: TimeFrame = .month
    
    enum TimeFrame: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case quarter = "This Quarter"
        case year = "This Year"
    }
    
    private var analytics: ProjectAnalytics {
        ProjectAnalytics(
            projects: projectViewModel.projects,
            activities: activityViewModel.activities,
            timeFrame: selectedTimeFrame
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time Frame Picker
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Overview Cards
                AnalyticsOverviewSection(analytics: analytics)
                
                // Project Status Chart
                ProjectStatusChartSection(analytics: analytics)
                
                // Activity Distribution
                ActivityDistributionSection(analytics: analytics)
                
                // Task Completion Trend
                TaskCompletionTrendSection(analytics: analytics)
            }
            .padding(.vertical)
        }
        .navigationTitle("Analytics")
    }
}

struct AnalyticsOverviewSection: View {
    let analytics: ProjectAnalytics
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            AnalyticCard(
                title: "Active Projects",
                value: "\(analytics.activeProjectsCount)",
                trend: analytics.projectCountTrend
            )
            
            AnalyticCard(
                title: "Total Hours",
                value: String(format: "%.1f", analytics.totalHours),
                trend: analytics.hoursTrend
            )
            
            AnalyticCard(
                title: "Task Completion",
                value: String(format: "%.0f%%", analytics.taskCompletionRate),
                trend: analytics.completionRateTrend
            )
            
            AnalyticCard(
                title: "Urgent Tasks",
                value: "\(analytics.urgentTasksCount)",
                trend: analytics.urgentTasksTrend
            )
        }
        .padding(.horizontal)
    }
}

struct AnalyticCard: View {
    let title: String
    let value: String
    let trend: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .bold()
            
            HStack {
                Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text("\(abs(trend), specifier: "%.1f")%")
                    .font(.caption)
            }
            .foregroundColor(trend >= 0 ? .green : .red)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
} 