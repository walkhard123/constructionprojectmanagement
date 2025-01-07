import SwiftUI

struct TeamView: View {
    @ObservedObject var projectViewModel: ProjectViewModel
    @StateObject private var teamViewModel = TeamViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            Picker("View", selection: $selectedTab) {
                Text("Members").tag(0)
                Text("Attendance").tag(1)
                Text("Projects").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                TeamMembersView(viewModel: teamViewModel)
                    .tag(0)
                
                AttendanceView(viewModel: teamViewModel)
                    .tag(1)
                
                TeamProjectsView(
                    viewModel: teamViewModel,
                    projectViewModel: projectViewModel
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Team")
    }
} 