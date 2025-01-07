import Foundation

struct TeamMember: Identifiable {
    let id: UUID
    var name: String
    var role: Role
    var email: String
    var phone: String
    var isActive: Bool
    var skills: Set<Skill>
    var assignedProjects: Set<UUID> // Project IDs
    
    enum Role: String, CaseIterable {
        case manager = "Project Manager"
        case supervisor = "Supervisor"
        case worker = "Worker"
        case engineer = "Engineer"
        case contractor = "Contractor"
    }
    
    enum Skill: String, CaseIterable {
        case carpentry = "Carpentry"
        case electrical = "Electrical"
        case plumbing = "Plumbing"
        case hvac = "HVAC"
        case masonry = "Masonry"
        case welding = "Welding"
    }
} 