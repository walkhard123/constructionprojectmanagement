import SwiftUI
import Charts

struct ActivityLogView: View {
    @ObservedObject var activityViewModel: ActivityViewModel
    let project: Project?
    @State private var showingNewActivitySheet = false
    @State private var selectedTimeFrame: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var filteredActivities: [Activity] {
        let calendar = Calendar.current
        let filterDate: Date = {
            switch selectedTimeFrame {
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            case .year:
                return calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            }
        }()
        
        return activityViewModel.activities.filter { $0.date >= filterDate }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Analytics Header
            ActivityAnalyticsHeader(
                activities: filteredActivities,
                timeFrame: selectedTimeFrame
            )
            
            // Time Frame Picker
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Activity Chart
            ActivityChart(activities: filteredActivities)
                .frame(height: 200)
                .padding()
            
            // Activity List
            List {
                ForEach(filteredActivities) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
        .navigationTitle(project?.name ?? "All Activities")
        .toolbar {
            Button(action: { showingNewActivitySheet = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingNewActivitySheet) {
            ActivityFormView(
                activityViewModel: activityViewModel,
                project: project
            )
        }
    }
}

struct ActivityAnalyticsHeader: View {
    let activities: [Activity]
    let timeFrame: ActivityLogView.TimeFrame
    
    private var totalHours: Double {
        activities.reduce(0) { $0 + $1.hoursSpent }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Hours")
                        .font(.headline)
                    Text(String(format: "%.1f", totalHours))
                        .font(.title)
                        .foregroundColor(.blue)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Activities")
                        .font(.headline)
                    Text("\(activities.count)")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(radius: 1)
    }
}

struct ActivityChart: View {
    let activities: [Activity]
    
    var body: some View {
        Chart {
            ForEach(Activity.ActivityType.allCases, id: \.self) { type in
                let hours = activities
                    .filter { $0.type == type }
                    .reduce(0) { $0 + $1.hoursSpent }
                
                BarMark(
                    x: .value("Type", type.rawValue),
                    y: .value("Hours", hours)
                )
                .foregroundStyle(by: .value("Type", type.rawValue))
            }
        }
    }
}

struct ActivityRow: View {
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
                
                Text(String(format: "%.1f hrs", activity.hoursSpent))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(activity.description)
                .font(.body)
            
            Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
} 