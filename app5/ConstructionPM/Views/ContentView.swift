import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var projectViewModel: ProjectViewModel
    @StateObject private var taskViewModel: TaskViewModel
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _projectViewModel = StateObject(wrappedValue: ProjectViewModel(context: context))
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(context: context))
    }
    
    var body: some View {
        MainMenuView(
            projectViewModel: projectViewModel,
            taskViewModel: taskViewModel
        )
    }
}

#Preview {
    ContentView(context: PersistenceController(inMemory: true).container.viewContext)
} 