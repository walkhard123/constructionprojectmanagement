import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleTaskReminder(task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.isUrgent ? "Urgent Task Reminder" : "Task Reminder"
        content.body = "\(task.title) is due on \(task.dueDate.formatted(date: .abbreviated, time: .omitted))"
        content.sound = .default
        
        // Schedule notifications for different intervals
        scheduleNotification(for: task, days: 1, content: content)
        if task.isUrgent {
            scheduleNotification(for: task, days: 3, content: content)
            scheduleNotification(for: task, days: 7, content: content)
        }
    }
    
    private func scheduleNotification(for task: Task, days: Int, content: UNNotificationContent) {
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -days, to: task.dueDate) else { return }
        
        // Only schedule if trigger date is in the future
        guard triggerDate > Date() else { return }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "\(task.id.uuidString)-\(days)days",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotifications(for task: Task) {
        let identifiers = [
            "\(task.id.uuidString)-1days",
            "\(task.id.uuidString)-3days",
            "\(task.id.uuidString)-7days"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
} 