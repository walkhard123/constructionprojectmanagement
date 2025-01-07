import UIKit
import PDFKit

class ProjectReportPDFRenderer {
    let report: ProjectReport
    
    init(report: ProjectReport) {
        self.report = report
    }
    
    func generatePDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Construction PM",
            kCGPDFContextAuthor: "Construction PM App",
            kCGPDFContextTitle: "\(report.project.name) - \(report.period.title)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let titleBottom = addTitle(pageRect: pageRect)
            let summaryBottom = addSummary(pageRect: pageRect, afterY: titleBottom)
            let tasksBottom = addTasksProgress(pageRect: pageRect, afterY: summaryBottom)
            addActivityLog(pageRect: pageRect, afterY: tasksBottom)
        }
        
        return data
    }
    
    private func addTitle(pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont
        ]
        
        let title = "\(report.project.name) - \(report.period.title)"
        let titleStringSize = title.size(withAttributes: titleAttributes)
        let titleStringRect = CGRect(
            x: (pageRect.width - titleStringSize.width) / 2.0,
            y: 36,
            width: titleStringSize.width,
            height: titleStringSize.height
        )
        
        title.draw(in: titleStringRect, withAttributes: titleAttributes)
        return titleStringRect.maxY
    }
    
    private func addSummary(pageRect: CGRect, afterY: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 12.0)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        
        let summary = """
        Total Hours: \(String(format: "%.1f", report.totalHours))
        Completion Rate: \(String(format: "%.1f%%", report.taskCompletionRate))
        Activities: \(report.activities.count)
        """
        
        let summaryRect = CGRect(
            x: 36,
            y: afterY + 20,
            width: pageRect.width - 72,
            height: 60
        )
        
        summary.draw(in: summaryRect, withAttributes: attributes)
        return summaryRect.maxY
    }
    
    private func addTasksProgress(pageRect: CGRect, afterY: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 12.0)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        
        let tasksProgress = """
        Tasks Progress
        Completed Tasks: \(report.completedTasksCount) of \(report.project.tasks.count)
        """
        
        let rect = CGRect(
            x: 36,
            y: afterY + 20,
            width: pageRect.width - 72,
            height: 40
        )
        
        tasksProgress.draw(in: rect, withAttributes: attributes)
        return rect.maxY
    }
    
    private func addActivityLog(pageRect: CGRect, afterY: CGFloat) {
        let font = UIFont.systemFont(ofSize: 10.0)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        
        var currentY = afterY + 20
        
        let activities = report.activities.sorted(by: { $0.date > $1.date })
        for activity in activities {
            let activityText = """
            \(activity.date.formatted()): \(activity.type.rawValue)
            \(activity.description)
            Hours: \(String(format: "%.1f", activity.hoursSpent))
            
            """
            
            let rect = CGRect(
                x: 36,
                y: currentY,
                width: pageRect.width - 72,
                height: 60
            )
            
            activityText.draw(in: rect, withAttributes: attributes)
            currentY = rect.maxY + 10
        }
    }
} 