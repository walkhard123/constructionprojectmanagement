import Foundation

func isInTimeFrame(date: Date, start: Date, end: Date) -> Bool {
    return date >= start && date <= end
} 