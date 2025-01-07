import SwiftUI

enum LocationStatus: Equatable {
    case unknown
    case authorized
    case denied
    case verifying
    case verified
    case failed(String)
    
    var message: String {
        switch self {
        case .unknown: return "Location Unknown"
        case .authorized: return "Location Available"
        case .denied: return "Location Access Denied"
        case .verifying: return "Verifying Location..."
        case .verified: return "Location Verified"
        case .failed(let error): return error
        }
    }
} 