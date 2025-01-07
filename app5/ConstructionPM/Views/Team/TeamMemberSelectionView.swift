import SwiftUI

struct TeamMemberSelectionView: View {
    @Binding var selectedMembers: Set<UUID>
    @StateObject private var teamViewModel = TeamViewModel()
    @State private var showingMemberPicker = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // Show selected members
            if !selectedMembers.isEmpty {
                ForEach(teamViewModel.members.filter { selectedMembers.contains($0.id) }) { member in
                    HStack {
                        Text(member.name)
                        Spacer()
                        Button(action: { removeMember(member.id) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // Add member button
            Button(action: { showingMemberPicker = true }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text(selectedMembers.isEmpty ? "Add Team Members" : "Add More Members")
                }
            }
        }
        .sheet(isPresented: $showingMemberPicker) {
            TeamMemberPickerView(
                selectedMembers: $selectedMembers,
                teamViewModel: teamViewModel
            )
        }
    }
    
    private func removeMember(_ id: UUID) {
        selectedMembers.remove(id)
    }
}

struct TeamMemberPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMembers: Set<UUID>
    @ObservedObject var teamViewModel: TeamViewModel
    @State private var searchText = ""
    
    var filteredMembers: [TeamMember] {
        if searchText.isEmpty {
            return teamViewModel.members.filter { $0.isActive }
        }
        return teamViewModel.members.filter { member in
            member.isActive &&
            (member.name.localizedCaseInsensitiveContains(searchText) ||
             member.role.rawValue.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredMembers) { member in
                    Button(action: { toggleMemberSelection(member) }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(member.name)
                                    .foregroundColor(.primary)
                                Text(member.role.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedMembers.contains(member.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search team members")
            .navigationTitle("Select Team Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func toggleMemberSelection(_ member: TeamMember) {
        if selectedMembers.contains(member.id) {
            selectedMembers.remove(member.id)
        } else {
            selectedMembers.insert(member.id)
        }
    }
}

#Preview {
    TeamMemberSelectionView(selectedMembers: .constant([]))
} 