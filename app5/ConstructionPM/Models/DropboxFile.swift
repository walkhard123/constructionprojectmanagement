import Foundation

struct DropboxFile: Identifiable {
    let id: String
    let name: String
    let path: String
    let modifiedDate: Date
    
    var icon: String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.fill"
        case "jpg", "jpeg", "png": return "photo.fill"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "chart.bar.doc.horizontal.fill"
        default: return "doc"
        }
    }
} 