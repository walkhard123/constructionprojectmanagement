import Foundation

struct Attendance: Identifiable {
    let id: UUID
    let memberId: UUID
    let date: Date
    let checkInTime: Date
    var checkOutTime: Date?
    var status: Status
    var notes: String?
    
    enum Status: String {
        case present = "Present"
        case absent = "Absent"
        case late = "Late"
        case leave = "On Leave"
    }
    
    var totalHours: Double {
        guard let checkOut = checkOutTime else { return 0 }
        return checkOut.timeIntervalSince(checkInTime) / 3600
    }
} 