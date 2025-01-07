import SwiftUI
import SwiftyDropbox

@main
struct ConstructionPMApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Keep Core Data initialization
        UUIDSetTransformer.register()
        
        // Initialize Dropbox
        DropboxClientsManager.setupWithAppKey("0daj8nkuwpeg9sv")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
} 
