import Foundation

struct DailyLog: Identifiable {
    let id: UUID
    let date: Date
    let projectId: UUID?
    var workSummary: String
    var weather: WeatherType
    var numberOfWorkers: Int
    var hoursWorked: Double
    var issues: String?
    
    enum WeatherType: String, CaseIterable {
        case sunny = "Sunny"
        case cloudy = "Cloudy"
        case rainy = "Rainy"
        
        var icon: String {
            switch self {
            case .sunny: return "sun.max.fill"
            case .cloudy: return "cloud.fill"
            case .rainy: return "cloud.rain.fill"
            }
        }
    }
    
    init(id: UUID = UUID(), 
         date: Date = Date(),
         projectId: UUID? = nil,
         workSummary: String = "",
         weather: WeatherType = .sunny,
         numberOfWorkers: Int = 0,
         hoursWorked: Double = 0,
         issues: String? = nil) {
        self.id = id
        self.date = date
        self.projectId = projectId
        self.workSummary = workSummary
        self.weather = weather
        self.numberOfWorkers = numberOfWorkers
        self.hoursWorked = hoursWorked
        self.issues = issues
    }
} 