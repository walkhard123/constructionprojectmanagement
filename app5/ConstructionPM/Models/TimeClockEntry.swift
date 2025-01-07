import Foundation
import CoreLocation

struct TimeClockEntry: Identifiable {
    let id: UUID
    let userId: UUID
    let projectId: UUID?
    let clockInTime: Date
    var clockOutTime: Date?
    let clockInLocation: LocationData
    var clockOutLocation: LocationData?
    var notes: String?
    var status: SessionStatus
    
    init(id: UUID = UUID(),
         userId: UUID,
         projectId: UUID? = nil,
         clockInTime: Date,
         clockOutTime: Date? = nil,
         clockInLocation: LocationData,
         clockOutLocation: LocationData? = nil,
         notes: String? = nil,
         status: SessionStatus = .active) {
        self.id = id
        self.userId = userId
        self.projectId = projectId
        self.clockInTime = clockInTime
        self.clockOutTime = clockOutTime
        self.clockInLocation = clockInLocation
        self.clockOutLocation = clockOutLocation
        self.notes = notes
        self.status = status
    }
    
    enum SessionStatus: String {
        case active = "Active"
        case completed = "Completed"
        case invalid = "Invalid"
    }
}

struct LocationData {
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
    let accuracy: CLLocationAccuracy
    let isVerified: Bool
    
    init(coordinate: CLLocationCoordinate2D,
         timestamp: Date,
         accuracy: CLLocationAccuracy,
         isVerified: Bool) {
        self.coordinate = coordinate
        self.timestamp = timestamp
        self.accuracy = accuracy
        self.isVerified = isVerified
    }
    
    var isValid: Bool {
        accuracy <= 100 // Consider valid if accuracy is within 100 meters
    }
} 