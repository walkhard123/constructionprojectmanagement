import Foundation

@MainActor
class TeamViewModel: ObservableObject {
    @Published private(set) var members: [TeamMember] = []
    @Published private(set) var attendance: [Attendance] = []
    @Published var selectedDate = Date()
    
    // MARK: - Team Members
    func addMember(_ member: TeamMember) {
        members.append(member)
    }
    
    func updateMember(_ member: TeamMember) {
        if let index = members.firstIndex(where: { $0.id == member.id }) {
            members[index] = member
        }
    }
    
    func toggleMemberStatus(_ memberId: UUID) {
        if let index = members.firstIndex(where: { $0.id == memberId }) {
            members[index].isActive.toggle()
        }
    }
    
    // MARK: - Attendance
    func checkIn(memberId: UUID) {
        let attendance = Attendance(
            id: UUID(),
            memberId: memberId,
            date: selectedDate,
            checkInTime: Date(),
            status: .present
        )
        self.attendance.append(attendance)
    }
    
    func checkOut(memberId: UUID) {
        if let index = attendance.firstIndex(where: { 
            $0.memberId == memberId && 
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate) 
        }) {
            attendance[index].checkOutTime = Date()
        }
    }
    
    // MARK: - Project Assignment
    func assignToProject(memberId: UUID, projectId: UUID) {
        if let index = members.firstIndex(where: { $0.id == memberId }) {
            members[index].assignedProjects.insert(projectId)
        }
    }
    
    func removeFromProject(memberId: UUID, projectId: UUID) {
        if let index = members.firstIndex(where: { $0.id == memberId }) {
            members[index].assignedProjects.remove(projectId)
        }
    }
} 