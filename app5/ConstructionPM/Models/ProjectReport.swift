import Foundation

struct ProjectReport {
    let project: Project
    let activities: [Activity]
    let period: ReportPeriod
    
    enum ReportPeriod: Hashable {
        case week
        case month
        case quarter
        case year
        case custom(from: Date, to: Date)
        
        var title: String {
            switch self {
            case .week: return "Weekly Report"
            case .month: return "Monthly Report"
            case .quarter: return "Quarterly Report"
            case .year: return "Yearly Report"
            case .custom: return "Custom Period Report"
            }
        }
    }
    
    var totalHours: Double {
        activities.reduce(0) { $0 + $1.hoursSpent }
    }
    
    var hoursPerType: [Activity.ActivityType: Double] {
        Dictionary(grouping: activities, by: { $0.type })
            .mapValues { activities in
                activities.reduce(0) { $0 + $1.hoursSpent }
            }
    }
    
    var completedTasksCount: Int {
        project.tasks.filter { $0.status == .completed }.count
    }
    
    var taskCompletionRate: Double {
        guard !project.tasks.isEmpty else { return 0 }
        return Double(completedTasksCount) / Double(project.tasks.count) * 100
    }
} 