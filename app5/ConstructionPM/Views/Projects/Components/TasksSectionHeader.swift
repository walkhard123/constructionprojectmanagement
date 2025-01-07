import SwiftUI

struct TasksSectionHeader: View {
    @Binding var selectedFilter: TaskFilter
    
    var body: some View {
        HStack {
            Text("Tasks")
                .font(.headline)
            Spacer()
            Picker("Filter", selection: $selectedFilter) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
        }
    }
} 