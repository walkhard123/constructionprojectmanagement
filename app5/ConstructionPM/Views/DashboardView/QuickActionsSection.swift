import SwiftUI

struct QuickActionsSection: View {
    @State private var showingNewTaskSheet = false
    @State private var showingLogActivitySheet = false
    @State private var showingLeaveRequestSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            HStack(spacing: 16) {
                QuickActionButton(
                    title: "New Task",
                    systemImage: "plus.circle.fill",
                    color: .blue
                ) {
                    showingNewTaskSheet = true
                }
                
                QuickActionButton(
                    title: "Log Activity",
                    systemImage: "clock.fill",
                    color: .green
                ) {
                    showingLogActivitySheet = true
                }
                
                QuickActionButton(
                    title: "Leave Request",
                    systemImage: "calendar.badge.plus",
                    color: .orange
                ) {
                    showingLeaveRequestSheet = true
                }
            }
        }
        .sheet(isPresented: $showingNewTaskSheet) {
            NewTaskView()
        }
        .sheet(isPresented: $showingLogActivitySheet) {
            LogActivityView()
        }
        .sheet(isPresented: $showingLeaveRequestSheet) {
            LeaveRequestView()
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(10)
        }
    }
} 