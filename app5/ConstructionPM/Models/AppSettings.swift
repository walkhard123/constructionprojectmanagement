import Foundation

struct AppSettings: Codable {
    var notificationsEnabled: Bool
    var reminderTime: Date
    var defaultProjectView: ProjectViewType
    var autoCheckOverdueTasks: Bool
    var defaultActivityDuration: Double
    
    enum ProjectViewType: String, Codable {
        case list
        case grid
        case timeline
    }
    
    static var `default`: AppSettings {
        AppSettings(
            notificationsEnabled: true,
            reminderTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
            defaultProjectView: .list,
            autoCheckOverdueTasks: true,
            defaultActivityDuration: 1.0
        )
    }
}

class SettingsManager: ObservableObject {
    @Published private(set) var settings: AppSettings
    private let defaults = UserDefaults.standard
    private let settingsKey = "appSettings"
    
    init() {
        if let data = defaults.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = settings
        } else {
            self.settings = .default
            save()
        }
    }
    
    func updateSettings(_ settings: AppSettings) {
        self.settings = settings
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: settingsKey)
        }
    }
} 