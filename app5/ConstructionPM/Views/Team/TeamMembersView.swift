import SwiftUI

struct TeamMembersView: View {
    @ObservedObject var viewModel: TeamViewModel
    @State private var showingAddMember = false
    @State private var searchText = ""
    
    var body: some View {
        List {
            ForEach(filteredMembers) { member in
                TeamMemberRow(member: member)
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.toggleMemberStatus(member.id)
                        } label: {
                            Label(member.isActive ? "Deactivate" : "Activate", 
                                  systemImage: member.isActive ? "person.fill.xmark" : "person.fill.checkmark")
                        }
                    }
            }
        }
        .searchable(text: $searchText, prompt: "Search members")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddMember = true }) {
                    Label("Add Member", systemImage: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingAddMember) {
            AddTeamMemberView(viewModel: viewModel)
        }
    }
    
    private var filteredMembers: [TeamMember] {
        if searchText.isEmpty {
            return viewModel.members
        }
        return viewModel.members.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.role.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct TeamMemberRow: View {
    let member: TeamMember
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(member.name)
                    .font(.headline)
                Spacer()
                MemberStatusBadge(isActive: member.isActive)
            }
            
            Text(member.role.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !member.skills.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(member.skills), id: \.self) { skill in
                            Text(skill.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
    }
}

struct MemberStatusBadge: View {
    let isActive: Bool
    
    var body: some View {
        Text(isActive ? "Active" : "Inactive")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .foregroundColor(isActive ? .green : .gray)
            .cornerRadius(4)
    }
} 