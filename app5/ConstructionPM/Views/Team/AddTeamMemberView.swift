import SwiftUI

struct AddTeamMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TeamViewModel
    
    @State private var name = ""
    @State private var role = TeamMember.Role.worker
    @State private var email = ""
    @State private var phone = ""
    @State private var selectedSkills = Set<TeamMember.Skill>()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
                
                Section("Role") {
                    Picker("Role", selection: $role) {
                        ForEach(TeamMember.Role.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                }
                
                Section("Skills") {
                    ForEach(TeamMember.Skill.allCases, id: \.self) { skill in
                        Toggle(skill.rawValue, isOn: Binding(
                            get: { selectedSkills.contains(skill) },
                            set: { isSelected in
                                if isSelected {
                                    selectedSkills.insert(skill)
                                } else {
                                    selectedSkills.remove(skill)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Add Team Member")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") { addMember() }
                    .disabled(name.isEmpty || email.isEmpty || phone.isEmpty)
            )
        }
    }
    
    private func addMember() {
        let member = TeamMember(
            id: UUID(),
            name: name,
            role: role,
            email: email,
            phone: phone,
            isActive: true,
            skills: selectedSkills,
            assignedProjects: []
        )
        
        viewModel.addMember(member)
        dismiss()
    }
} 