import Foundation

struct ProjectAnalytics {
    let projects: [Project]
    let activities: [Activity]
    let timeFrame: DashboardAnalyticsView.TimeFrame
    
    var activeProjectsCount: Int {
        projects.filter { !$0.tasks.isEmpty }.count
    }
    
    var totalHours: Double {
        activities.filter { isInTimeFrame($0.date) }
            .reduce(0) { $0 + $1.hoursSpent }
    }
    
    var taskCompletionRate: Double {
        let allTasks = projects.flatMap { $0.tasks }
        guard !allTasks.isEmpty else { return 0 }
        let completedTasks = allTasks.filter { $0.status == .completed }
        return Double(completedTasks.count) / Double(allTasks.count) * 100
    }
    
    var urgentTasksCount: Int {
        projects.flatMap { $0.tasks }.filter { $0.isUrgent }.count
    }
    
    // Trends (mock data - in real app would compare with previous period)
    var projectCountTrend: Double { 15.0 }
    var hoursTrend: Double { -5.0 }
    var completionRateTrend: Double { 8.0 }
    var urgentTasksTrend: Double { -12.0 }
    
    func isInTimeFrame(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeFrame {
        case .week:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .month:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .quarter:
            let quarterStart = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return date >= quarterStart && date <= now
        case .year:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }
} 