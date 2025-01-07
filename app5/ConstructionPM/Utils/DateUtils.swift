import Foundation

extension Date {
    func isInTimeFrame(from start: Date, to end: Date) -> Bool {
        return self >= start && self <= end
    }
} 