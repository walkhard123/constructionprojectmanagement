import Foundation

@MainActor
class DailyLogViewModel: ObservableObject {
    @Published private(set) var logs: [DailyLog] = []
    
    func addLog(_ log: DailyLog) {
        logs.append(log)
        // TODO: Save to persistent storage
        print("Log added: \(log)")
    }
} 